import pandas

### Uncomment lines below for SQL Server; Change the server name
#import pyodbc as db  # SQL Server
#conn = db.connect('Driver={SQL Server};'
#                 'Server=YOUR_SERVER_NAME_GOES_HERE;'
#                'Server=SQLServer-PC;'
#                'Database=us_national_statistics;'
#                 'Trusted_Connection=yes;')

### Uncomment lines below  for PostgreSQL; Change the user and password
# before connecting to the database, in the notebook cell, execute: !pip install psycopg2-binary

import psycopg2 as pg # PostgreSQL
conn = pg.connect("dbname=us_national_statistics user=postgres password=BU669")


cursor = conn.cursor()

stateQuery = 'select numeric_id, us_state_terr, abbreviation, is_state from states'

cursor.execute(stateQuery)

stateInfo = cursor.fetchall()

# declare a dictionary
stateIsState = {}

for thisState in stateInfo:
    print (thisState[2])
    stateIsState[thisState[2]] = thisState[3]
    stateIsState[thisState[1]] = thisState[3]

datFrame = pandas.read_sql(stateQuery, conn)

for statename in datFrame.us_state_terr:
    print (statename)

def is_it_a_state(stateabbrv):
    if stateabbrv in stateIsState:
        if stateIsState[stateabbrv] == "State":
            return ("yes, " + stateabbrv + " is a state")
        else:
            return ("no, " + stateabbrv + " is not a state")
    else:
        return (stateabbrv + " is not in the dictionary")

print (is_it_a_state('NY'))

print (is_it_a_state('MP'))

print (is_it_a_state('QQ'))
