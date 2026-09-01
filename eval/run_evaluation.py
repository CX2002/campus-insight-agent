"""Run the three project-level evaluation metrics against the local services."""

import argparse
import asyncio
import json
from decimal import Decimal, InvalidOperation
from pathlib import Path
from typing import Any

from app.agent.context import DataAgentContext
from app.agent.graph import graph
from app.agent.state import DataAgentState
from app.clients.embedding_client_manager import embedding_client_manager
from app.clients.es_client_manager import es_client_manager
from app.clients.mysql_client_manager import (
    dw_mysql_client_manager,
    meta_mysql_client_manager,
)
from app.clients.qdrant_client_manager import qdrant_client_manager
from app.repositories.es.value_es_repository import ValueESRepository
from app.repositories.mysql.dw.dw_mysql_repository import DWMySQLRepository
from app.repositories.mysql.meta.meta_mysql_repository import MetaMySQLRepository
from app.repositories.qdrant.column_qdrant_repository import ColumnQdrantRepository
from app.repositories.qdrant.metric_qdrant_repository import MetricQdrantRepository


def normalize_value(value: Any) -> str:
    """Normalize numeric representations so 10, 10.0 and 10.00 compare equally."""
    if isinstance(value, (int, float, Decimal)):
        return format(Decimal(str(value)).quantize(Decimal("0.01")), "f")
    if isinstance(value, str):
        try:
            return format(Decimal(value).quantize(Decimal("0.01")), "f")
        except InvalidOperation:
            return value
    return str(value)


def normalize_rows(rows: Any) -> list[list[str]]:
    """Normalize row order and compare returned values independent of SQL aliases."""
    if not isinstance(rows, list):
        rows = [rows]
    normalized: list[list[str]] = []
    for row in rows:
        if not isinstance(row, dict):
            row = {"value": row}
        normalized.append([normalize_value(value) for value in row.values()])
    return sorted(normalized, key=lambda row: json.dumps(row, ensure_ascii=False))


async def evaluate(dataset_path: Path) -> dict[str, Any]:
    cases = json.loads(dataset_path.read_text(encoding="utf-8"))
    for manager in (
        meta_mysql_client_manager,
        dw_mysql_client_manager,
        qdrant_client_manager,
        embedding_client_manager,
        es_client_manager,
    ):
        manager.init()

    try:
        async with (
            meta_mysql_client_manager.session_factory() as meta_session,
            dw_mysql_client_manager.session_factory() as dw_session,
        ):
            context = DataAgentContext(
                column_qdrant_repository=ColumnQdrantRepository(
                    qdrant_client_manager.client
                ),
                embedding_client=embedding_client_manager.client,
                metric_qdrant_repository=MetricQdrantRepository(
                    qdrant_client_manager.client
                ),
                value_es_repository=ValueESRepository(es_client_manager.client),
                meta_mysql_repository=MetaMySQLRepository(meta_session),
                dw_mysql_repository=DWMySQLRepository(dw_session),
            )
            dw_repository = context["dw_mysql_repository"]
            result_correct = 0
            reciprocal_rank_total = 0.0
            details = []

            for case in cases:
                gold_rows = await dw_repository.run(case["gold_sql"])
                generated_rows = None
                retrieved_ids: list[str] = []
                try:
                    async for event in graph.astream(
                        input=DataAgentState(query=case["question"]),
                        context=context,
                        stream_mode="custom",
                    ):
                        if event.get("step") == "召回字段信息" and event.get(
                            "retrieved_ids"
                        ):
                            retrieved_ids = event["retrieved_ids"]
                        if event.get("type") == "result":
                            generated_rows = event.get("data")
                    executed = generated_rows is not None
                except Exception:
                    executed = False

                correct = executed and normalize_rows(
                    generated_rows
                ) == normalize_rows(gold_rows)
                expected = set(case["expected_columns"])
                top_k = retrieved_ids
                result_correct += int(correct)
                first_rank = next(
                    (rank for rank, column_id in enumerate(top_k, 1) if column_id in expected),
                    None,
                )
                reciprocal_rank_total += 1 / first_rank if first_rank else 0.0
                details.append(
                    {
                        "question": case["question"],
                        "result_correct": correct,
                        "mrr": (1 / first_rank if first_rank else 0.0),
                    }
                )
    finally:
        await qdrant_client_manager.close()
        await es_client_manager.close()
        await meta_mysql_client_manager.close()
        await dw_mysql_client_manager.close()
    return {
        "total_cases": len(cases),
        "rag_mrr": round(reciprocal_rank_total / len(cases), 4),
        "end_to_end_result_accuracy": round(result_correct / len(cases), 4),
        "details": details,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Evaluate Campus Insight Agent")
    parser.add_argument(
        "-d", "--dataset", type=Path, default=Path("eval/questions.json")
    )
    parser.add_argument(
        "-o", "--output", type=Path, default=Path("eval/latest_result.json")
    )
    args = parser.parse_args()
    try:
        report = asyncio.run(evaluate(args.dataset))
    except Exception as exc:
        print(
            "评测启动失败：无法连接本地依赖服务。"
            "请先运行 docker compose -f docker/docker-compose.yaml up -d。"
        )
        raise SystemExit(2) from exc
    args.output.write_text(
        json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print(
        json.dumps(
            {key: report[key] for key in report if key != "details"},
            ensure_ascii=False,
            indent=2,
        )
    )
