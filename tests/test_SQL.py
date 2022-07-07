import pytest
import psycopg2


conn = psycopg2.connect(
    host='localhost',
    dbname='postgres',
    user='postgres',
    password='postgres'
)
cursor = conn.cursor()


def test_q1():
    cursor.execute("""
        SELECT crew_name
        FROM crew_members
        WHERE birth_date = (
            SELECT MIN(birth_date)
            FROM crew_members);
    """)
    assert cursor.fetchone()[0] == "Frank Abagnale"


def test_q2():
    cursor.execute("""
        SELECT crew_name
        FROM crew_members
        WHERE birth_date = (
            SELECT birth_date 
            FROM crew_members
            ORDER BY birth_date ASC
            LIMIT 1 OFFSET 1);
    """)
    assert cursor.fetchone()[0] == "Chesley Sully Sullenberger"


def test_q3():
    cursor.execute("""
        DROP VIEW IF EXISTS crew_exp;
        
        CREATE VIEW crew_exp AS
            SELECT crew_id, COUNT(aircraft_name) AS exp_level
            FROM aircrafts
            GROUP BY crew_id;
            
        SELECT crew_name
        FROM crew_members
        WHERE crew_id = (
            SELECT crew_id
            FROM crew_exp
            WHERE exp_level = (
                SELECT MAX(exp_level)
                FROM crew_exp));
    """)
    assert cursor.fetchone()[0] == "Pete Maverick Mitchell"


def test_q4():
    cursor.execute("""
        DROP VIEW IF EXISTS crew_exp;

        CREATE VIEW crew_exp AS
            SELECT crew_id, COUNT(aircraft_name) AS exp_level
            FROM aircrafts
            GROUP BY crew_id;

        SELECT crew_name
        FROM crew_members
        WHERE crew_id = (
            SELECT crew_id
            FROM crew_exp
            WHERE exp_level = (
                SELECT MIN(exp_level)
                FROM crew_exp));
    """)
    assert cursor.fetchone()[0] == "Frank Abagnale"


pytest.main(["test_SQL.py", "-v"])
