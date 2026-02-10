/* 
Анализ удержания студентов (Retention) по партнёрским каналам
Для онлайн-школы (продуктовая аналитика)
*/

SELECT
    name_partner,
    -- Абсолютные числа по покупкам
    SUM(CASE WHEN rn = 1 THEN 1 ELSE 0 END) AS cnt_1st_purchase,
    SUM(CASE WHEN rn = 2 THEN 1 ELSE 0 END) AS cnt_2nd_purchase,
    SUM(CASE WHEN rn = 3 THEN 1 ELSE 0 END) AS cnt_3rd_purchase,
    -- Относительный ретеншен (доля от первой покупки)
    ROUND(SUM(CASE WHEN rn = 2 THEN 1.0 ELSE 0 END) / 
          NULLIF(SUM(CASE WHEN rn = 1 THEN 1 END), 0), 3) AS retention_2nd,
    ROUND(SUM(CASE WHEN rn = 3 THEN 1.0 ELSE 0 END) / 
          NULLIF(SUM(CASE WHEN rn = 1 THEN 1 END), 0), 3) AS retention_3rd
FROM (
    SELECT 
        a.*,
        b.name_partner,
        -- Нумерация покупок для каждого студента
        ROW_NUMBER() OVER(PARTITION BY a.user_id ORDER BY a.date_purchase ASC) AS rn
    FROM skycinema.client_sign_up a
    JOIN skycinema.partner_dict b
        ON a.partner = b.id_partner
    WHERE a.status = 'success'  -- Только успешные покупки
) t
GROUP BY name_partner
ORDER BY retention_2nd DESC;
