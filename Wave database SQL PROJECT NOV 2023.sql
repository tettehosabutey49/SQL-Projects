-- Q1 How many agent_transactions did we have in the momths of 2022(broken down by month)
SELECT MONTHNAME(when_created) months, COUNT(atx_id)
FROM agent_transactions atx
GROUP BY MONTHNAME(when_created);

-- Q2 Over the course of the first half of 2022, how many wave agents were "net depositors" vs "net withdrawers"
-- both conditions were done seperately and then "net_withdrawers" was put into the net_deposit's select statement just to have it in a new column
SELECT COUNT(atx_id) AS net_depositor, (SELECT COUNT(atx_id) AS net_withdrawers
FROM agent_transactions
WHERE amount > 0 AND MONTH(when_created) < 6) AS net_withdrawers
FROM agent_transactions
WHERE amount < 0 AND MONTH(when_created) < 6;

-- Q2 Using another method
-- Here, we create two seperate tables net_deposit and netwithdraw and join them 
SELECT net_depositor, net_withdrawers
FROM 
(
(SELECT COUNT(atx_id) AS net_depositor
FROM agent_transactions
WHERE amount < 0 AND MONTH(when_created) < 6) AS net_d
JOIN
(SELECT COUNT(atx_id) AS net_withdrawers
FROM agent_transactions
WHERE amount > 0 AND MONTH(when_created) < 6) AS net_w
);

-- Using CTEs in Conditional Logic for a similar solution in Q2
WITH table1 AS (
SELECT agent_id, SUM(amount) AS volume
FROM agent_transactions
WHERE (
		YEAR(when_created) = 2022
				AND
			MONTH(when_created) <=6
		)
      GROUP BY agent_id
      )

SELECT COUNT(*) AS counts,
	CASE 
		WHEN volume < 0 THEN 'net_depositors'
        WHEN volume > 0 THEN 'net withdrawers'
        ELSE 'not allowed'
	END AS agent_net_type
    FROM table1
    GROUP BY 2;
    
-- Q3 Build an atx volume by "country and kind table" table. Find the volume of agent transactions created in the first half of 2022, grouped by city. 
-- You can determine the city where the agent transaction took place from the agent's city field
SELECT SUM(amount) volume, city
FROM agent_transactions agtt
JOIN agents
ON agents.agent_id = agtt.agent_id
WHERE MONTH(agtt.when_created) < 6
GROUP BY city ;

-- Q4 Seperate the atx column by country as well
SELECT SUM(amount) volume, city, country
FROM agent_transactions agtt
JOIN agents
ON agents.agent_id = agtt.agent_id
WHERE MONTH(agtt.when_created) < 6
GROUP BY city, country;

-- Q5 Build a "volume by country and kind" table. Find the total number of transfers(by send_amount_scalar) sent in the first half of 2022, grouped by 
-- country and trasfer kind
SELECT country, kind , SUM(send_amount_scalar) transfer_volume
FROM agents ag
JOIN agent_transactions agtt
ON agtt.agent_id = ag.agent_id
JOIN transfers t
ON t.user_id = agtt.u_id
WHERE MONTH(t.when_created) < 6
GROUP BY country, kind;

-- Q6 Then add columns for transaction count and number of unique senders (still broken down by country and transfer kind )
SELECT country, kind , SUM(send_amount_scalar) transfer_volume, COUNT(atx_id) trans_count, COUNT(user_id) unique_senders
FROM agents ag
JOIN agent_transactions agtt
ON agtt.agent_id = ag.agent_id
JOIN transfers t
ON t.user_id = agtt.u_id
WHERE MONTH(t.when_created) < 6
GROUP BY country, kind;

-- Q7 Which wallets sent more than 1,000,000 CFA in transfers in the first half
-- (as identified by the source_wallet_id column on the transfers table), and how much did they send
SELECT source_wallet_id, send_amount_currency, SUM(send_amount_scalar) AS total_trans_per_wallet_over_1M, MONTHNAME(when_created) months
FROM transfers
WHERE send_amount_scalar > 1000000 AND MONTH(when_created) <7
GROUP BY source_wallet_id, send_amount_currency, MONTHNAME(when_created)
