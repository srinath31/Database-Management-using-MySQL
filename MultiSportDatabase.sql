CREATE TABLE Sport
(
SportID VARCHAR(20) NOT NULL,
SportName VARCHAR(20) NOT NULL,
CountryOfOrigin VARCHAR(20),
AverageTRP FLOAT,

CONSTRAINT Sport_ID PRIMARY KEY (SportID)
);

CREATE TABLE League
(
LeagueID VARCHAR(20) NOT NULL,
LeagueName VARCHAR(20) NOT NULL,
Country VARCHAR(20) NOT NULL,
DateOfEst DATE,

CONSTRAINT League_ID PRIMARY KEY (LeagueID)
);

CREATE TABLE Player
(
PlayerID VARCHAR(20) NOT NULL,
FirstName VARCHAR(20) NOT NULL,
LastName VARCHAR(20) NOT NULL,
Country VARCHAR(20),
Age NUMERIC(10,0),
DateOfDebut DATE NOT NULL,

CONSTRAINT Player_ID PRIMARY KEY (PlayerID)
);

CREATE TABLE Team
(
TeamID VARCHAR(20) NOT NULL,
TeamName VARCHAR(20) NOT NULL,
TeamType VARCHAR(20) NOT NULL,
TeamAnthem VARCHAR(20),
SportID VARCHAR(20),
LeagueID VARCHAR(20),

CONSTRAINT Team_ID PRIMARY KEY (TeamID),
CONSTRAINT sport_ID_fk FOREIGN KEY(SportID) REFERENCES Sport(SportID),
CONSTRAINT league_ID_fk FOREIGN KEY(LeagueID) REFERENCES League(LeagueID)
);

CREATE TABLE ViewerRatingSource
(
SourceID VARCHAR(20) NOT NULL,
SourceName VARCHAR(20) NOT NULL,
SourceType VARCHAR(20) NOT NULL,

CONSTRAINT Source_ID PRIMARY KEY (SourceID)
);

CREATE TABLE PlayerTeamRecord
(
PlayerID VARCHAR(20) NOT NULL,
TeamID VARCHAR(20) NOT NULL,
NumberOfMatchesPlayed NUMERIC(10,0),

CONSTRAINT playerteam_composite PRIMARY KEY(PlayerID,TeamID),
CONSTRAINT playerID_fk FOREIGN KEY(PlayerID) REFERENCES Player(PlayerID),
CONSTRAINT teamID_fk FOREIGN KEY(TeamID) REFERENCES Team(TeamID)
)


CREATE TABLE RatingRecord
(
SourceID VARCHAR(20) NOT NULL,
SportID VARCHAR(20) NOT NULL,
YearRange VARCHAR(20) NOT NULL,
Rating FLOAT NOT NULL,

CONSTRAINT sourcesport_composite PRIMARY KEY(SourceID,SportID),
CONSTRAINT sportID_fk FOREIGN KEY(SportID) REFERENCES Sport(SportID),
CONSTRAINT sourceID_fk FOREIGN KEY(SourceID) REFERENCES ViewerRatingSource(SourceID)
)


INSERT INTO Sport VALUES('SP001', 'Baseball', 'USA', 7.5);
INSERT INTO Sport VALUES('SP002', 'Basketball', 'USA', 8.5);
INSERT INTO Sport VALUES('SP003', 'Cricket', 'England', 8);
INSERT INTO Sport VALUES('SP004', 'Kabaddi', 'India', 7);
INSERT INTO Sport VALUES('SP005', 'Soccer', 'England', 9.5);


INSERT INTO League VALUES('L001', 'MLB', 'USA', '01-01-1903');
INSERT INTO League VALUES('L002', 'NBA', 'USA', '01-01-1946');
INSERT INTO League VALUES('L003', 'IPL', 'India', '01-01-2008');
INSERT INTO League VALUES('L004', 'Big Bash', 'Australia', '01-01-2010');
INSERT INTO League VALUES('L005', 'EPL', 'England', '01-01-1992');
INSERT INTO League VALUES('L006', 'NCAA', 'USA', '01-01-1968');

INSERT INTO Player VALUES('P001', 'Mike', 'Trout', 'USA',35,'01-01-2005');
INSERT INTO Player VALUES('P002', 'LeBron', 'James', 'USA',34,'01-01-2003');
INSERT INTO Player VALUES('P003', 'Roberto', 'Firmino', 'Brasil',26,'01-01-2012');
INSERT INTO Player VALUES('P004', 'Virat', 'Kohli', 'India',30,'01-01-2008');
INSERT INTO Player VALUES('P005', 'Anup', 'Kumar', 'India',35,'01-01-2007');

INSERT INTO Team VALUES('T001', 'Liverpool', 'National', 'You Never Walk Alone','SP005','L005');
INSERT INTO Team VALUES('T002', 'RCB', 'National', 'NA','SP003','L003');
INSERT INTO Team VALUES('T003', 'Syracuse Orange', 'Domestic', 'NA','SP002','L006');
INSERT INTO Team VALUES('T004', 'Los Angeles Angels', 'National', 'Build Me Up','SP001','L001');
INSERT INTO Team VALUES('T006', 'Melbourne Renegades', 'National', 'NA','SP003','L004');
INSERT INTO Team VALUES('T007', 'Chelsea', 'National', 'KTBFFH','SP005','L005');

INSERT INTO ViewerRatingSource VALUES('S001', 'ESPN Ratings', 'Web Browsing');
INSERT INTO ViewerRatingSource VALUES('S002', 'FOX Sport Ratings', 'Television');
INSERT INTO ViewerRatingSource VALUES('S003', 'Hotstar', 'Online Streaming');

INSERT INTO PlayerTeamRecord VALUES('P001', 'T004', 100);
INSERT INTO PlayerTeamRecord VALUES('P003', 'T001', 150);
INSERT INTO PlayerTeamRecord VALUES('P004', 'T002', 135);
INSERT INTO PlayerTeamRecord VALUES('P007', 'T007', 50);


INSERT INTO RatingRecord VALUES('S001', 'SP005','2015-2016', 10);
INSERT INTO RatingRecord VALUES('S002', 'SP005','2015-2016', 9);
INSERT INTO RatingRecord VALUES('S003', 'SP003','2015-2016', 7);
INSERT INTO RatingRecord VALUES('S002', 'SP003','2015-2016', 9);
INSERT INTO RatingRecord VALUES('S003', 'SP005','2015-2016', 9);
INSERT INTO RatingRecord VALUES('S001', 'SP003','2015-2016', 9);
INSERT INTO RatingRecord VALUES('S001', 'SP001','2015-2016', 9);
INSERT INTO RatingRecord VALUES('S002', 'SP001','2015-2016', 8);
INSERT INTO RatingRecord VALUES('S001', 'SP002','2015-2016', 8);
INSERT INTO RatingRecord VALUES('S002', 'SP002','2015-2016', 9.5);
INSERT INTO RatingRecord VALUES('S001', 'SP004','2015-2016', 7);
INSERT INTO RatingRecord VALUES('S002', 'SP004','2015-2016', 8);

INSERT INTO RatingRecord VALUES('S003', 'SP001','2015-2016', 10);


--SELECT Commands
select * from Sport
select * from Player
select * from league
select * from team
select * from ViewerRatingSource
select * from PlayerTeamRecord
select * from RatingRecord
SELECT * FROM Sport;
	

--DROP Commands
drop table RatingRecord	
drop table ViewerRatingSource
drop table PlayerTeamRecord
drop table Team
drop table Sport
drop table Player
drop table League


select year(getdate())-year(dateofdebut) from player;

--alter table Player add ProfessionalExperience VARCHAR(10);

alter table Player
drop column ProfessionalExperience



--Creating Trigger to automatically update Average TRP once a new rating is received from a source.
CREATE TRIGGER updateSport
	ON RatingRecord
	FOR INSERT,UPDATE,DELETE
	AS
	IF @@ROWCOUNT>=1
	BEGIN
		UPDATE Sport
		SET AverageTRP=s.avg_ratings
	FROM(SELECT r.SportID AS sportID,CAST(AVG(r.rating) AS DECIMAL(12,2)) AS avg_ratings
         FROM RatingRecord AS r
         WHERE r.yearrange='2015-2016'
         GROUP BY r.SportID) AS s 
	WHERE s.sportID=Sport.sportID
	END;

drop trigger updateSport


--to identify a player has played how many matches for a team.
SELECT p.FirstName,p.LastName,p.Country,p.Age,t.TeamName,pt.NumberOfMatchesPlayed
FROM Player p 
INNER JOIN PlayerTeamRecord pt
ON p.PlayerID=pt.PlayerID 
INNER JOIN Team t
ON t.TeamID=pt.TeamID

--To identify a Player has played for how many teams
SELECT p.FirstName,p.LastName,COUNT(t.teamName) AS NumberOfTeamsPlayedFor
FROM Player p
INNER JOIN PlayerTeamRecord pt
ON pt.PlayerID=p.PlayerID
INNER JOIN team t
ON t.TeamID=pt.TeamID
GROUP BY p.FirstName,p.LastName
ORDER BY p.FirstName ASC


SELECT SportName,CountryOfOrigin,AverageTRP
FROM Sport;





--Creating a procedure to idenify the professional experience of a player in terms of number of years.
create procedure profexp
AS
BEGIN
	UPDATE Player
	SET ProfessionalExperience=YEAR(GETDATE())-
							   (select Year(DateofDebut)
							    from Player)
	where ProfessionalExperience='NULL'
END;

drop procedure profexp
execute profexp

--To identify a sport has how many leagues.
SELECT s.SportName,count(t.LeagueID) as NumberofLeagues
FROM Sport s
INNER JOIN Team t
ON t.SportID=s.SportID
GROUP BY s.SportName


SET XACT_ABORT ON;
BEGIN TRANSACTION newTeam

INSERT INTO Player 
VALUES('P008', 'MS', 'Dhoni', 'India',35,'01-01-2005');

INSERT INTO Team 
VALUES('T008', 'CSK', 'National', 'NA','SP003','L003');

INSERT INTO PlayerTeamRecord 
VALUES('P008', 'T008', 200);

COMMIT TRANSACTION newTeam;



SELECT * FROM Player
SELECT * FROM team
SELECT * FROM PlayerTeamRecord
