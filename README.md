# Продуктовая аналитика и расчёт удержания для онлайн-школы

**Заказчик:** Онлайн-платформа изучения языков (NDA).  
**Задача:** Оценить качество образовательного контента, проанализировать поведение учеников после первой покупки и рассчитать метрики удержания по каналам привлечения.  
**Срок:** 1 неделя.  
**Стек:** PostgreSQL, оконные функции (ROW_NUMBER, LAG), CTE, подзапросы.

## Результат

1.  **Контроль качества уроков:** Выявлены аномалии в расписании (уроки <20 мин и >2.5 ч) для проверки технических сбоев.
2.  **Проверка гипотез:** Опровергнута гипотеза о связи объёма пакета уроков с их средней длительностью. Подтверждено сезонное падение доходов в 2017 году.
3.  **Расчёт ретеншена:** Построена воронка удержания по 15+ партнёрским каналам, выявлены наиболее эффективные источники трафика.
4.  **Оптимизация процессов:** Определены часы с максимальной вероятностью успешного заказа для логистического сервиса (смежный кейс).

## Ключевой запрос: анализ удержания (Retention)

```sql
/* Расчёт доли студентов, дошедших до каждой последующей покупки, по партнёрским каналам */
SELECT
    name_partner,
    SUM(CASE WHEN rn = 1 THEN 1 ELSE 0 END) AS cnt_1,
    SUM(CASE WHEN rn = 2 THEN 1 ELSE 0 END) AS cnt_2,
    SUM(CASE WHEN rn = 3 THEN 1 ELSE 0 END) AS cnt_3,
    ROUND(SUM(CASE WHEN rn = 2 THEN 1.0 ELSE 0 END) / 
          SUM(CASE WHEN rn = 1 THEN 1 END), 3) AS retention_2nd,
    ROUND(SUM(CASE WHEN rn = 3 THEN 1.0 ELSE 0 END) / 
          SUM(CASE WHEN rn = 1 THEN 1 END), 3) AS retention_3rd
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY date_purchase ASC) AS rn
    FROM skycinema.client_sign_up a
    JOIN skycinema.partner_dict b
        ON a.partner = b.id_partner
) t
GROUP BY name_partner
ORDER BY retention_2nd DESC;
