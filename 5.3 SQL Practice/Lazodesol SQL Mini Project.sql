/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT name
FROM  `Facilities`
WHERE membercost >0


/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(name) 
FROM  `Facilities` 
WHERE membercost != 0


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance
FROM  `Facilities` 
WHERE membercost < .2 * monthlymaintenance AND membercost != 0


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT * 
FROM  `Facilities` 
WHERE facid
IN ( 1, 5 ) 


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance, 
CASE WHEN monthlymaintenance <100 THEN  'cheap'
	 ELSE  'expensive' END AS 'Cheap or Expensive'
FROM `Facilities`


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT firstname, surname, joindate
FROM `Members`
WHERE joindate = (
	SELECT MAX(joindate) 
	FROM `Members`
	)


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT facs.name AS court, CONCAT(memb.firstname,  ' ', memb.surname) AS fullname
FROM country_club.Members as memb
INNER JOIN country_club.Bookings as books ON memb.memid = books.memid
INNER JOIN country_club.Facilities as facs ON books.facid = facs.facid
WHERE facs.facid
IN (0, 1) 
GROUP BY fullname


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT facs.name, memb.firstname AS fullname, facs.guestcost * books.slots AS totalcost
FROM country_club.Bookings as books
JOIN country_club.Facilities as facs ON books.facid = facs.facid
JOIN country_club.Members as memb ON memb.memid = books.memid
WHERE books.starttime LIKE '2012-09-14%' AND memb.memid = 0
UNION SELECT facs.name, CONCAT(memb.firstname,  ' ', memb.surname) AS fullname, SUM(facs.membercost * books.slots) AS totalcost
FROM country_club.Bookings as books
JOIN country_club.Facilities as facs ON books.facid = facs.facid
JOIN country_club.Members as memb ON memb.memid = books.memid
WHERE books.starttime LIKE '2012-09-14%' AND memb.memid != 0
GROUP BY fullname
HAVING totalcost > 30
ORDER BY totalcost DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT sub1.name, memb1.firstname AS fullname, sub1.totalcost
FROM country_club.Members AS memb1
JOIN (
SELECT books.memid, facs.name, books.slots * guestcost AS totalcost
FROM country_club.Bookings AS books
JOIN country_club.Facilities AS facs ON books.facid = facs.facid
WHERE books.starttime LIKE '2012-09-14%'
AND memid =0
) AS sub1 ON memb1.memid = sub1.memid
WHERE totalcost > 30
UNION 
SELECT sub2.name, CONCAT(memb2.firstname,  ' ', memb2.surname) AS fullname, sub2.totalcost
FROM country_club.Members AS memb2
JOIN (
SELECT books.memid, facs.name, SUM(facs.membercost * books.slots) AS totalcost
FROM country_club.Bookings AS books
JOIN country_club.Facilities AS facs ON books.facid = facs.facid
JOIN country_club.Members AS memb2 ON memb2.memid = books.memid
WHERE books.starttime LIKE '2012-09-14%'
AND memb2.memid !=0
GROUP BY memb2.memid
) AS sub2 ON memb2.memid = sub2.memid
WHERE totalcost > 30
ORDER BY totalcost DESC


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT facs.name, SUM(
CASE WHEN books.memid = 0 THEN facs.guestcost * books.slots
ELSE facs.membercost * books.slots END) AS revenue
FROM country_club.Facilities AS facs
JOIN country_club.Bookings AS books ON facs.facid = books.facid
GROUP BY facs.name
HAVING revenue < 10000
ORDER BY revenue DESC
