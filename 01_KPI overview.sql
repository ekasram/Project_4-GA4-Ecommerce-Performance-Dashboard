  select 
    count(distinct case when event_name='session_start' then 
    concat(user_pseudo_id, '-',
    (select value.int_value from unnest(event_params) where key='ga_session_id')) end) as visits,

    count(distinct case when event_name='purchase'then ecommerce.transaction_id end) as orders,

    sum(case when event_name='purchase'then ecommerce.purchase_revenue_in_usd end) as sales,

    count(distinct case when event_name= 'view_item'then 
    concat(user_pseudo_id, '-',
    (select value.int_value from unnest(event_params) where key='ga_session_id')) end) as view_item,

    count(distinct case when event_name = 'add_to_cart' then 
    concat(user_pseudo_id, '-',
    (select value.int_value from unnest(event_params) where key='ga_session_id')) end) as add_to_cart,
    
    count(distinct case when event_name = 'begin_checkout' then 
    concat(user_pseudo_id, '-',
    (select value.int_value from unnest(event_params) where key='ga_session_id')) end) as begin_checkout,

    count(distinct case when event_name = 'add_shipping_info' then 
    concat(user_pseudo_id, '-',
    (select value.int_value from unnest(event_params) where key='ga_session_id')) end) as add_shipping_info,

    count(distinct case when event_name = 'add_payment_info' then 
    concat(user_pseudo_id, '-',
    (select value.int_value from unnest(event_params) where key='ga_session_id')) end) as add_payment_info,

  from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
