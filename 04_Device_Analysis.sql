WITH events AS (
  SELECT
    device.category AS category,
    device.language AS language,
    device.operating_system AS operating_system,
    event_name,
    CONCAT(user_pseudo_id, '-',
      (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id')
    ) AS session_id,
    ecommerce.purchase_revenue_in_usd AS revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
)
SELECT
  category, language, operating_system,
  COUNT(DISTINCT CASE WHEN event_name = 'session_start' THEN session_id END) AS visits,
  COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN session_id END) AS purchases,
  ROUND(SUM(CASE WHEN event_name = 'purchase' THEN revenue END), 2) AS sales
FROM events
GROUP BY category, language, operating_system;