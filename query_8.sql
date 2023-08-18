--find the winner in  each group.
--winner in each group is the player who scored the max total points within the group.
--in case of tie, the lowest player_id wins.

create table players
(player_id int,
group_id int)

insert into players values (15,1);
insert into players values (25,1);
insert into players values (30,1);
insert into players values (45,1);
insert into players values (10,2);
insert into players values (35,2);
insert into players values (50,2);
insert into players values (20,3);
insert into players values (40,3);

create table matches
(
match_id int,
first_player int,
second_player int,
first_score int,
second_score int)

insert into matches values (1,15,45,3,0);
insert into matches values (2,30,25,1,2);
insert into matches values (3,30,15,2,0);
insert into matches values (4,40,20,5,2);
insert into matches values (5,35,50,1,1);

--select * from players
--select * from matches

with grouped as (
select players, sum(scores) as total_scores
from (
select first_player as players, first_score as scores
from matches
union all
select second_player as players, second_score as scores
from matches) A
group by players)
, cte as (
select *, 
dense_rank() over(partition by p.group_id order by g.total_scores desc) as score_flag, 
dense_rank() over(partition by p.group_id order by g.players desc) as player_order_flag
from players p
inner join grouped g on p.player_id = g.players)
, cte2 as (
select *, 
dense_rank() over(partition by group_id order by player_order_flag desc) as second_player_order_flag
from cte
where score_flag = 1)

select group_id, player_id, total_scores
from cte2
where second_player_order_flag = 1