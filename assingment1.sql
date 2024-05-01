create database ticketbookingsystem;

create table if not exists venu (
    venue_id int primary key auto_increment,
    venue_name varchar(255) not null,
    address varchar(255) not null
);

create table if not exists event (
    event_id int primary key auto_increment,
    event_name varchar(255) not null,
    event_date date not null,
    event_time time not null,
    venue_id int,
    total_seats int,
    available_seats int,
    ticket_price decimal(10, 2),
    event_type enum('movie', 'sports', 'concert'),
    booking_id int,
    foreign key (venue_id) references venu(venue_id) on delete set null,
    foreign key (booking_id) references booking(booking_id) on delete set null
);

create table if not exists customer (
    customer_id int primary key auto_increment,
    customer_name varchar(255) not null,
    email varchar(255),
    phone_number varchar(15),
    booking_id int,
    foreign key (booking_id) references booking(booking_id) on delete set null
);

create table if not exists booking (
    booking_id int primary key auto_increment,
    customer_id int,
    event_id int,
    num_tickets int,
    total_cost decimal(10, 2),
    booking_date datetime default current_timestamp,
    foreign key (customer_id) references customer(customer_id) on delete set null,
    foreign key (event_id) references event(event_id) on delete cascade
);

insert into venu (venue_name, address) values
('venue 1', 'address 1'),
('venue 2', 'address 2'),
('venue 3', 'address 3'),
('venue 4', 'address 4'),
('venue 5', 'address 5');

insert into event (event_name, event_date, event_time, venue_id, total_seats, available_seats, ticket_price, event_type)
values
('event 1', '2024-05-01', '18:00:00', 1, 200, 100, 1500.00, 'movie'),
('event 2', '2024-05-02', '19:00:00', 2, 150, 50, 2000.00, 'sports'),
('event 3', '2024-05-03', '20:00:00', 3, 300, 200, 1800.00, 'concert'),
('event 4', '2024-05-04', '21:00:00', 4, 250, 100, 2200.00, 'movie'),
('event 5', '2024-05-05', '22:00:00', 5, 400, 300, 2500.00, 'concert');

insert into customer (customer_name, email, phone_number)
values
('john doe', 'john@example.com', '1234560001'),
('jane smith', 'jane@example.com', '2345670002'),
('alice johnson', 'alice@example.com', '3456780003'),
('bob brown', 'bob@example.com', '4567890004'),
('emily davis', 'emily@example.com', '5678900005');

insert into booking (customer_id, event_id, num_tickets, total_cost)
values
(1, 1, 2, 3000.00),
(2, 2, 3, 6000.00),
(3, 3, 4, 7200.00),
(4, 4, 2, 4400.00),
(5, 5, 5, 12500.00);

select * from event;

select * from event where available_seats > 0;

select * from event where event_name like '%cup%';

select * from event where ticket_price between 1000 and 2500;

select * from event where event_date between '2024-05-01' and '2024-05-05';

select * from event where available_seats > 0 and event_name like '%concert%';

select * from customer limit 5 offset 5;

select * from booking where num_tickets > 4;

select * from customer where phone_number like '%000';

select * from event where total_seats > 15000 order by event_name;

select * from event where event_name not like 'x%' and event_name not like 'y%' and event_name not like 'z%';

select event_id, event_name, avg(ticket_price) as avg_ticket_price
from event
group by event_id, event_name;

select sum(total_cost) as total_revenue
from booking;

select event_id, event_name, sum(num_tickets) as total_tickets_sold
from booking
group by event_id, event_name
order by total_tickets_sold desc
limit 1;

select event_id, event_name, sum(num_tickets) as total_tickets_sold
from booking
group by event_id, event_name;

select event_id, event_name
from event
left join booking on event.event_id = booking.event_id
where booking.booking_id is null;

select customer_id, customer_name, count(booking_id) as total_bookings
from booking
group by customer_id, customer_name
order by total_bookings desc
limit 1;

select month(event_date) as month, sum(num_tickets) as total_tickets_sold
from booking
join event on booking.event_id = event.event_id
group by month(event_date);

select venue_id, venue_name, avg(ticket_price) as avg_ticket_price
from event
join venu on event.venue_id = venu.venue_id
group by venue_id, venue_name;

select event_type, sum(num_tickets) as total_tickets_sold
from event
join booking on event.event_id = booking.event_id
group by event_type;

select year(event_date) as year, sum(total_cost) as total_revenue
from booking
join event on booking.event_id = event.event_id
group by year(event_date);

select customer_id, customer_name, count(distinct event_id) as total_events_booked
from booking
join customer on booking.customer_id = customer.customer_id
group by customer_id, customer_name
having total_events_booked > 1;

select customer_id, customer_name, sum(total_cost) as total_revenue
from booking
join customer on booking.customer_id = customer.customer_id
group by customer_id, customer_name;

select venu.venue_id, venu.venue_name, event.event_type, avg(event.ticket_price) as avg_ticket_price
from event
join venu on event.venue_id = venu.venue_id
group by venu.venue_id, venu.venue_name, event.event_type;

select customer_id, customer_name, count(booking_id) as total_tickets_purchased
from booking
join customer on booking.customer_id = customer.customer_id
where booking_date >= date_sub(curdate(), interval 30 day)
group by customer_id, customer_name;

select venue_id, venue_name,
       (select avg(ticket_price) 
        from event 
        where event.venue_id = venu.venue_id) as avg_ticket_price
from venu;

select event_id, event_name
from event
where (select sum(num_tickets) from booking where booking.event_id = event.event_id) > 0.5 * total_seats;

select event.event_id, event.event_name, coalesce(sum(booking.num_tickets), 0) as total_tickets_sold
from event
left join booking on event.event_id = booking.event_id
group by event.event_id, event.event_name;

select customer_id, customer_name
from customer
where not exists (
    select * from booking where booking.customer_id = customer.customer_id
);

select event_id, event_name
from event
where event_id not in (select distinct event_id from booking);

select event_type, sum(total_tickets_sold) as total_tickets_sold
from (
    select event.event_type, coalesce(sum(booking.num_tickets), 0) as total_tickets_sold
    from event
    left join booking on event.event_id = booking.event_id
    group by event.event_id, event.event_type
) as subquery
group by event_type;

select event_id, event_name, ticket_price
from event
where ticket_price > (select avg(ticket_price) from event);

select customer.customer_id, customer.customer_name,
       (select coalesce(sum(booking.total_cost), 0) 
        from booking 
        where booking.customer_id = customer.customer_id) as total_revenue
from customer;

select customer_id, customer_name
from customer
where exists (
    select * from booking
    join event on booking.event_id = event.event_id
    where event.venue_id = (select venue_id from venu where venue_name = 'given venue name')
      and booking.customer_id = customer.customer_id
);

select event_type, coalesce(sum(total_tickets_sold), 0) as total_tickets_sold
from (
    select event.event_type, coalesce(sum(booking.num_tickets), 0) as total_tickets_sold
    from event
    left join booking on event.event_id = booking.event_id
    group by event.event_id, event.event_type
) as subquery
group by event_type;

select customer_id, customer_name, month(booking_date) as booking_month
from booking
join customer on booking.customer_id = customer.customer_id
group by customer_id, customer_name, booking_month;

select venue_id, venue_name,
       (select avg(ticket_price) 
        from event 
        where event.venue_id = venu.venue_id) as avg_ticket_price
from venu;

