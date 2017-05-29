CREATE DATABASE IF NOT EXISTS login;

USE login;


CREATE TABLE Users(
UserID int NOT NULL AUTO_INCREMENT,
Username VARCHAR(255) NOT NULL UNIQUE,
Password VARCHAR(255) NOT NULL,
UserEnabled VARCHAR(1) NOT NULL,
IsAdmin VARCHAR(1),
PRIMARY KEY (UserID)
);

CREATE TABLE Sessions(
SessionID int NOT NULL AUTO_INCREMENT,
REQUEST_TIME int NOT NULL,
SessionUserID int NOT NULL,
FOREIGN KEY (SessionUserID) REFERENCES Users(UserID),
REMOTE_ADDR VARCHAR(255) NOT NULL,
HTTP_USER_AGENT VARCHAR(255) NOT NULL,
Random_String VARCHAR(8) NOT NULL,
fingerprint VARCHAR(255) NOT NULL UNIQUE,
PRIMARY KEY (SessionID)
);

CREATE UNIQUE INDEX fingerprint_index
ON Sessions (fingerprint);

CREATE TABLE badLoginAttempts(
badLoginID int NOT NULL AUTO_INCREMENT,
badREQUEST_TIME int NOT NULL,
badUsername VARCHAR(255) NOT NULL,
badREMOTE_ADDR VARCHAR(255) NOT NULL,
badHTTP_USER_AGENT VARCHAR(255) NOT NULL,
PRIMARY KEY (badLoginID)
);

CREATE TABLE blockedIPs(
BlockedID int NOT NULL AUTO_INCREMENT,
BlockedIP VARCHAR(255) NOT NULL UNIQUE,
PRIMARY KEY (BlockedID)
);

CREATE TABLE globalSettings(
settingID int NOT NULL AUTO_INCREMENT,
settingKey varchar(255) NOT NULL,
settingDesc longtext,
settingValue varchar(255) NOT NULL,
PRIMARY KEY (settingID)
);

CREATE UNIQUE INDEX BlockedIP_Indes
ON blockedIPs (BlockedIP);

INSERT INTO globalSettings (settingKey,settingDesc,settingValue) VALUES ('schemaVersion','This is the schema version of the DB. If it is lower than the expected version, conversion automatically happens to bring the DB up to date.','0');

INSERT INTO Users (Username,Password,UserEnabled,IsAdmin) VALUES ('admin','$2y$10$UivHA1lp.4e7fEDj.C6h9eWCGctGQtV3wlsJqaqTDMTih5ukDTaTi','1','1');

CREATE USER 'web'@'localhost' IDENTIFIED BY 'webpassword';

GRANT ALL ON login.blockedIPs TO 'web'@'localhost';
GRANT ALL ON login.Sessions TO 'web'@'localhost';
GRANT ALL ON login.badLoginAttempts TO 'web'@'localhost';
GRANT ALL ON login.Users TO 'web'@'localhost';
GRANT ALL ON login.globalSettings TO 'web'@'localhost';


