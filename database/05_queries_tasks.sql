-- 05_queries_tasks.sql
-- Required MySQL queries


-- 1) Hány darab sikeres tranzakció volt 2026-01-01 és 2026-02-28 között
-- és milyen módon fizették ki?

SELECT
  tfm.payment_method,
  COUNT(DISTINCT t.id) AS successful_transactions_count,
  SUM(tfm.amount_gross) AS paid_gross_sum
FROM tranzakciok t
JOIN tranzakcio_fizetesi_modok tfm
  ON tfm.tranzakcio_id = t.id
WHERE t.status = 'sikeres'
AND t.created_at >= '2026-01-01'
AND t.created_at < '2026-03-01'
GROUP BY tfm.payment_method
ORDER BY successful_transactions_count DESC;



-- 2) Mennyi az egyes események kihasználtsága %-ban?

SELECT
  e.id,
  e.title,
  e.capacity,
  SUM(CASE WHEN j.status='eladott' THEN 1 ELSE 0 END) AS sold_count,
  ROUND(
    SUM(CASE WHEN j.status='eladott' THEN 1 ELSE 0 END)
    / e.capacity * 100,
    2
  ) AS utilization_percent
FROM esemenyek e
JOIN jegyek j ON j.esemeny_id=e.id
GROUP BY e.id;



-- 3) Eladások darabszáma és bruttó bevétel napi bontásban
-- fizetési módtól függetlenül 2026-01-01-től

SELECT
  DATE(created_at) AS nap,
  COUNT(*) AS tranzakcio_db,
  SUM(total_gross) AS brutto_bevetel
FROM tranzakciok
WHERE status='sikeres'
AND created_at>='2026-01-01'
GROUP BY nap
ORDER BY nap;



-- 4) Melyik az a 3 esemény amelyekre a legtöbb jegyet adták el

SELECT
  e.id,
  e.title,
  COUNT(*) AS sold_tickets
FROM jegyek j
JOIN esemenyek e
ON e.id=j.esemeny_id
WHERE j.status='eladott'
GROUP BY e.id
ORDER BY sold_tickets DESC
LIMIT 3;
