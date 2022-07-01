/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

select name, membercost
from Facilities
where membercost != 0.0

/* Q2: How many facilities do not charge a fee to members? */
select count(name)
from Facilities
where membercost = 0.0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
select facid, name, membercost, monthlymaintenance
from Facilities
where membercost != 0.0 and membercost < monthlymaintenance * 0.2


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
select facid, name, membercost, monthlymaintenance
from Facilities
where facid in (1,5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
select name, monthlymaintenance,
	case when monthlymaintenance > 100 then 'expensive'
		else 'cheap' end as label
from Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
Select surname, firstname, joindate
FROM Members
WHERE joindate = (select max(joindate) 
   from Members 
   )

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
select distinct Facilities.name, Bookings.memid, concat_ws (' ', Members.firstname, Members.surname) as membername
	from Facilities
		INNER JOIN Bookings ON Facilities.facid=Bookings.facid
		INNER JOIN Members ON Bookings.memid=Members.memid
			where name like 'Ten%'
order by Members.firstname


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
select F.name as facilityname, concat_ws (' ', M.firstname, M.surname) as membername, membercost*slots as totalcosts
from Bookings AS B
inner join Members AS M on B.memid=M.memid
inner join Facilities AS F on B.facid=F.facid
where starttime like '2012-09-14%'
and B.memid != 0
and membercost*slots > 30

UNION 

select F.name as facilityname, concat_ws (' ', M.firstname, M.surname) as membername, guestcost*slots as totalcosts
from Bookings AS B
inner join Members AS M on B.memid=M.memid
inner join Facilities AS F on B.facid=F.facid
where starttime like '2012-09-14%'
and B.memid = 0
and guestcost*slots > 30
order by totalcosts desc


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
select distinct F.name as facilityname, concat_ws (' ', M.firstname, M.surname) as membername, 
	case when B.memid != 0 then membercost*slots
        else guestcost*slots end as totalcosts
from (select facid, memid, slots, starttime 
		from Bookings 
		where starttime like '2012-09-14%') AS B
inner join Members AS M on B.memid=M.memid
inner join Facilities AS F on B.facid=F.facid
having totalcosts > 30
order by totalcosts desc



/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
select name, sum(costs) as revenue
from
	(select B.bookid, B.facid, B.memid, F.name, slots, (membercost*slots) AS costs

	from Bookings AS B
	inner join Members AS M on B.memid=M.memid
	inner join Facilities AS F on B.facid=F.facid
	where B.memid != 0 

	union

	select B.bookid, B.facid, B.memid, F.name, slots,(guestcost*slots) AS costs

	from Bookings AS B
	inner join Members AS M on B.memid=M.memid
	inner join Facilities AS F on B.facid=F.facid
	where B.memid = 0) as subquery

group by name
having revenue < 1000
order by revenue


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
SELECT DISTINCT M1.firstname, M1.surname, M2.firstname as firstnameR, M2.surname as surnameR
from Members as M1
INNER JOIN Members as M2
	ON M1.recommendedby = M2.memid
WHERE M1.recommendedby != ""
order by M1.surname, M1.firstname

/* Q12: Find the facilities with their usage by member, but not guests */
select B.facid, F.name, B.memid, M.firstname, M.surname
from Bookings as B
inner join Members AS M on B.memid=M.memid
inner join Facilities AS F on B.facid=F.facid
where B.memid != 0
order by B.memid

/* Q13: Find the facilities usage by month, but not guests */
select B.facid, F.name, EXTRACT(MONTH FROM starttime) as month
from Bookings as B
inner join Members AS M on B.memid=M.memid
inner join Facilities AS F on B.facid=F.facid
where B.memid != 0
order by month

