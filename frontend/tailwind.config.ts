/**
 * Tailwind CSS 主题配置
 * 定义前端项目的字体、颜色和阴影扩展
 */
import type { Config } from "tailwindcss";

export default {
  content: ["./index.html", "./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      fontFamily: {
        sans: [
          '"LXGW WenKai Screen"',
          '"Noto Sans SC"',
          '"PingFang SC"',
          '"Microsoft YaHei"',
          "sans-serif",
        ],
        mono: ['"JetBrains Mono"', '"SFMono-Regular"', "Consolas", "monospace"],
      },
      colors: {
        parchment: "#f4f7fb",
        ink: "#10243e",
        soot: "#0b1a2d",
        moss: "#137c8b",
        brass: "#d18b32",
        tomato: "#d95757",
        mist: "#dce7ef",
      },
      boxShadow: {
        line: "0 1px 0 rgba(16, 36, 62, 0.08)",
        panel: "0 24px 70px rgba(16, 36, 62, 0.14)",
      },
    },
  },
  plugins: [],
} satisfies Config;
