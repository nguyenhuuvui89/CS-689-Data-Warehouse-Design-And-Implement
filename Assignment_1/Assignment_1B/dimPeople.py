import pandas as pd

titanicfile = "titanic.csv"

titanic_ppl = pd.read_csv (titanicfile)

for index, ttnc_person in titanic_ppl.iterrows():
    print (index, "\t", ttnc_person['Name'], "\t", ttnc_person['Sex'], "\t", ttnc_person['Age'], "\t",
       int(ttnc_person['Pclass']), "\t", int(int(ttnc_person['Fare']) / 3), "\t",
       float(ttnc_person['Fare']) )


