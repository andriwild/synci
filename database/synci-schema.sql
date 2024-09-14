CREATE TABLE event (
  id int NOT NULL,
  name VARCHAR(255),
  description TEXT,
  start timestamp,
  "end" timestamp,
  PRIMARY KEY (id)
);


-- Insert a conference event
INSERT INTO event (id, name, description, start, "end")
VALUES (1, 'Annual Tech Conference', 'A gathering of industry professionals discussing latest tech trends', '2024-09-15 09:00:00', '2024-09-17 17:00:00');

-- Insert a concert event
INSERT INTO event (id, name, description, start, "end")
VALUES (2, 'Summer Music Festival', 'Outdoor music festival featuring various artists', '2024-07-01 14:00:00', '2024-07-01 23:00:00');

-- Insert a workshop event
INSERT INTO event (id, name, description, start, "end")
VALUES (3, 'Data Science Workshop', 'Hands-on workshop covering basics of data analysis and machine learning', '2024-10-05 10:00:00', '2024-10-05 16:00:00');

-- Insert a sports event
INSERT INTO event (id, name, description, start, "end")
VALUES (4, 'City Marathon', 'Annual city-wide marathon open to all skill levels', '2024-04-12 07:00:00', '2024-04-12 14:00:00');

-- Insert a cultural event
INSERT INTO event (id, name, description, start, "end")
VALUES (5, 'International Food Fair', 'Celebration of cuisines from around the world', '2024-08-20 11:00:00', '2024-08-22 20:00:00');
