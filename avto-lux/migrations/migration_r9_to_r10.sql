ALTER TABLE avtolux_pages ADD COLUMN next_elem integer NULL;

-- store sort by id
WITH sorted AS (
	SELECT
		row_number() OVER ( ORDER BY id ASC ) AS pos,
		id,
		title,
		next_elem
	FROM
		avtolux_pages
	ORDER BY
		id ASC
), shifted AS (
	SELECT
		row_number() OVER ( ORDER BY id ASC ) AS pos,
		id,
		title,
		next_elem
	FROM
		avtolux_pages
	ORDER BY
		id ASC
), merge AS (
	SELECT
		sorted.id as id,
		shifted.id as next_id
	FROM
		sorted
	INNER JOIN shifted ON (shifted.pos = sorted.pos + 1)
) UPDATE avtolux_pages SET
	next_elem = merge.next_id
FROM
	merge
WHERE
	avtolux_pages.id = merge.id;
-- last elem
UPDATE avtolux_pages SET next_elem = NULL FROM (
	SELECT id FROM avtolux_pages ORDER BY id DESC LIMIT 1
) AS last_one WHERE avtolux_pages.id = last_one.id;
