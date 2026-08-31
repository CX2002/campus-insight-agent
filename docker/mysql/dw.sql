SET NAMES utf8mb4;
CREATE DATABASE IF NOT EXISTS dw DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON dw.* TO 'didilili'@'%';
USE dw;
DROP TABLE IF EXISTS fact_consumption;
DROP TABLE IF EXISTS dim_student;
DROP TABLE IF EXISTS dim_stall;
DROP TABLE IF EXISTS dim_canteen;
DROP TABLE IF EXISTS dim_date;
CREATE TABLE dim_student (student_id VARCHAR(20) PRIMARY KEY, student_name VARCHAR(50), gender VARCHAR(10), college VARCHAR(80), grade VARCHAR(20), student_type VARCHAR(20));
INSERT INTO dim_student VALUES
('S001','张敏','女','计算机学院','大一','本科生'),('S002','李伟','男','经济学院','大二','本科生'),('S003','王芳','女','外国语学院','大三','本科生'),('S004','刘洋','男','机械学院','大四','本科生'),('S005','陈静','女','计算机学院','研一','研究生'),('S006','赵磊','男','数学学院','研二','研究生'),('S007','黄秀英','女','医学院','大二','本科生'),('S008','吴斌','男','材料学院','大三','本科生'),('S009','周燕','女','法学院','研一','研究生'),('S010','徐浩','男','计算机学院','大一','本科生'),
('S011','杨晨','男','经济学院','大一','本科生'),('S012','周宁','女','外国语学院','大二','本科生'),('S013','何俊','男','机械学院','大三','本科生'),('S014','林晓','女','数学学院','大四','本科生'),('S015','郭莹','女','医学院','研一','研究生'),('S016','马超','男','材料学院','研二','研究生'),('S017','唐璐','女','法学院','大一','本科生'),('S018','陈浩','男','计算机学院','大二','本科生'),('S019','沈悦','女','经济学院','大三','本科生'),('S020','吴涛','男','外国语学院','大四','本科生'),
('S021','赵欣','女','机械学院','研一','研究生'),('S022','孙磊','男','数学学院','研二','研究生'),('S023','蒋雯','女','医学院','大一','本科生'),('S024','郑凯','男','材料学院','大二','本科生'),('S025','谢雨','女','法学院','大三','本科生'),('S026','朱杰','男','计算机学院','大四','本科生'),('S027','韩雪','女','经济学院','研一','研究生'),('S028','罗成','男','外国语学院','研二','研究生'),('S029','方圆','女','机械学院','大一','本科生'),('S030','许航','男','数学学院','大二','本科生'),
('S031','魏芳','女','医学院','大三','本科生'),('S032','邓宇','男','材料学院','大四','本科生'),('S033','顾婷','女','法学院','研一','研究生'),('S034','何磊','男','计算机学院','研二','研究生'),('S035','陆瑶','女','经济学院','大一','本科生'),('S036','彭飞','男','外国语学院','大二','本科生'),('S037','潘洁','女','机械学院','大三','本科生'),('S038','胡凯','男','数学学院','大四','本科生'),('S039','邱敏','女','医学院','研一','研究生'),('S040','高远','男','材料学院','研二','研究生');
INSERT INTO dim_student (student_id, student_name, gender, college, grade, student_type)
WITH RECURSIVE seq(n) AS (SELECT 41 UNION ALL SELECT n + 1 FROM seq WHERE n < 500)
SELECT CONCAT('S', LPAD(n,3,'0')), CONCAT('学生',n), IF(MOD(n,2)=0,'男','女'),
       ELT(MOD(n,10)+1,'计算机学院','经济学院','外国语学院','机械学院','数学学院','医学院','材料学院','法学院','建筑学院','艺术学院'),
       ELT(MOD(n,6)+1,'大一','大二','大三','大四','研一','研二'),
       IF(MOD(n,5)=0,'研究生','本科生')
FROM seq;
CREATE TABLE dim_canteen (canteen_id VARCHAR(20) PRIMARY KEY, canteen_name VARCHAR(80), campus VARCHAR(40), floor VARCHAR(20), opening_year INT);
INSERT INTO dim_canteen VALUES ('C001','紫金港第一食堂','紫金港校区','一楼',2012),('C002','紫金港风味食堂','紫金港校区','二楼',2018),('C003','玉泉学生食堂','玉泉校区','一楼',2005),('C004','西溪生活广场','西溪校区','一楼',2016);
CREATE TABLE dim_stall (stall_id VARCHAR(20) PRIMARY KEY, stall_name VARCHAR(80), canteen_id VARCHAR(20), category VARCHAR(40), brand VARCHAR(60), campus VARCHAR(40));
INSERT INTO dim_stall VALUES ('T001','一食堂快餐','C001','快餐','校园快餐','紫金港校区'),('T002','一食堂面档','C001','面食','兰州面馆','紫金港校区'),('T003','风味食堂清真档','C002','清真餐','清真餐厅','紫金港校区'),('T004','风味食堂小吃档','C002','小吃','江南小吃','紫金港校区'),('T005','玉泉自选餐','C003','自选餐','玉泉自选','玉泉校区'),('T006','西溪轻食店','C004','轻食','健康轻食','西溪校区');
CREATE TABLE dim_date (date_id INT PRIMARY KEY, year INT, quarter VARCHAR(4), month INT, day INT, week INT, day_of_week VARCHAR(10), holiday_flag TINYINT);
INSERT INTO dim_date VALUES (20250106,2025,'Q1',1,6,2,'星期一',0),(20250107,2025,'Q1',1,7,2,'星期二',0),(20250108,2025,'Q1',1,8,2,'星期三',0),(20250109,2025,'Q1',1,9,2,'星期四',0),(20250110,2025,'Q1',1,10,2,'星期五',0),(20250214,2025,'Q1',2,14,7,'星期五',0),(20250303,2025,'Q1',3,3,10,'星期一',0),(20250304,2025,'Q1',3,4,10,'星期二',0),(20250305,2025,'Q1',3,5,10,'星期三',0),(20250306,2025,'Q1',3,6,10,'星期四',0),(20250407,2025,'Q2',4,7,15,'星期一',0),(20250408,2025,'Q2',4,8,15,'星期二',0);
INSERT INTO dim_date VALUES (20250409,2025,'Q2',4,9,15,'星期三',0),(20250410,2025,'Q2',4,10,15,'星期四',0),(20250411,2025,'Q2',4,11,15,'星期五',0),(20250414,2025,'Q2',4,14,16,'星期一',0),(20250415,2025,'Q2',4,15,16,'星期二',0),(20250416,2025,'Q2',4,16,16,'星期三',0),(20250417,2025,'Q2',4,17,16,'星期四',0),(20250418,2025,'Q2',4,18,16,'星期五',0);
CREATE TABLE fact_consumption (consumption_id VARCHAR(30) PRIMARY KEY, student_id VARCHAR(20), stall_id VARCHAR(20), date_id INT, quantity INT, amount FLOAT, payment_method VARCHAR(20), meal_type VARCHAR(20), refund_flag TINYINT);
INSERT INTO fact_consumption (consumption_id,student_id,stall_id,date_id,quantity,amount,payment_method,meal_type,refund_flag)
SELECT CONCAT('CON', s.student_id, d.date_id, LPAD(m.meal_no,2,'0')),
       s.student_id,
       ELT(MOD(CAST(SUBSTRING(s.student_id,2) AS UNSIGNED)+d.day+m.meal_no,6)+1,'T001','T002','T003','T004','T005','T006'),
       d.date_id,
       1 + MOD(CAST(SUBSTRING(s.student_id,2) AS UNSIGNED)+m.meal_no,2),
       ROUND(9 + MOD(CAST(SUBSTRING(s.student_id,2) AS UNSIGNED)*3+d.day*2+m.meal_no*5,27) + m.meal_no*1.5, 2),
       ELT(MOD(CAST(SUBSTRING(s.student_id,2) AS UNSIGNED)+d.day,3)+1,'校园卡','微信','支付宝'),
       m.meal_type,
       IF(MOD(CAST(SUBSTRING(s.student_id,2) AS UNSIGNED)+d.day+m.meal_no,47)=0,1,0)
FROM dim_student s
CROSS JOIN dim_date d
CROSS JOIN (SELECT 1 meal_no,'早餐' meal_type UNION ALL SELECT 2,'午餐') m;
