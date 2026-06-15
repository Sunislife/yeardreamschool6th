
CREATE TABLE Author
(
  ID        INTEGER NOT NULL,
  Name      VARCHAR NOT NULL,
  Email     VARCHAR NULL    ,
  Biography VARCHAR NULL    ,
  PRIMARY KEY (ID)
);

CREATE TABLE Book
(
  ISBN             VARCHAR NOT NULL,
  Title            VARCHAR NULL    ,
  Publication_Date date    NULL    ,
  Genre            VARCHAR NULL    ,
  Author_ID        INTEGER NOT NULL,
  Customer_ID      INTEGER NOT NULL,
  PRIMARY KEY (ISBN)
);

CREATE TABLE Customer
(
  ID    INTEGER NOT NULL,
  Name  VARCHAR NULL    ,
  Email VARCHAR NULL    ,
  PRIMARY KEY (ID)
);

ALTER TABLE Book
  ADD CONSTRAINT FK_Author_TO_Book
    FOREIGN KEY (Author_ID)
    REFERENCES Author (ID);

ALTER TABLE Book
  ADD CONSTRAINT FK_Customer_TO_Book
    FOREIGN KEY (Customer_ID)
    REFERENCES Customer (ID);
