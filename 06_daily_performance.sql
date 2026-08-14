WITH events AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS date,
    event_name,
    CONCAT(user_pseudo_id, '-',
      (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id')
    ) AS session_id,
    ecommerce.transaction_id,
    ecommerce.purchase_revenue_in_usd AS revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
)
SELECT
  date,
  COUNT(DISTINCT CASE WHEN event_name = 'session_start' THEN session_id END) AS visits,
  COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN transaction_id END) AS orders,
  ROUND(SUM(CASE WHEN event_name = 'purchase' THEN revenue END), 2) AS sales
FROM events
GROUP BY date
ORDER BY date;