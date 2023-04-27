#!/usr/bin/env python
# coding: utf-8

# In[78]:


import pandas as pd
cases=pd.read_csv(r"C:/Users/Solangel R/Downloads/data.csv")


# In[80]:


icu=pd.read_json("https://opendata.ecdc.europa.eu/covid19/hospitalicuadmissionrates/json/")


# In[81]:


testing=pd.read_json('https://opendata.ecdc.europa.eu/covid19/testing/json/')


# In[82]:


covid=pd.concat([cases,icu,testing])


# In[83]:


covid.head(20)


# In[84]:


pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows',None)


# # Data Exploration

# In[85]:


#dropping columns
covid.drop(columns=['source','url'],inplace=True)


# In[86]:


#checking number of rows and columns
covid.shape


# In[87]:


icu.shape


# In[88]:


cases.shape


# In[89]:


testing.shape


# In[90]:


#name of each column
for col in covid.columns:
    print(col)


# In[91]:


#checking dtypes
covid.dtypes


# In[92]:


#converting and formatting dateRep to datetime
date='2020/11/26 12:00:00'
dateRep=pd.to_datetime(date, format='%Y/%m/%d %H:%M:%S')


# In[95]:


covid['dateRep']=pd.to_datetime(covid['dateRep'])


# In[96]:


covid['dateRep'].dtype


# In[97]:


covid['day']=covid['day'].convert_dtypes('Int32')


# In[98]:


covid['day'].dtypes


# In[99]:


covid['month']=covid['month'].convert_dtypes('Int32')


# In[100]:


covid['year']=covid['year'].convert_dtypes('Int32')


# In[263]:


covid.info()


# # Generating a statistical summary

# In[101]:


covid.describe()


# In[102]:


for i in covid['countriesAndTerritories'].unique():
    print(i)


# In[205]:


#value count to figure out categorical values
for col in covid:
        print ("{}:" .format((col)))
        print (len(covid[col].unique().tolist()))
        print('\n')


# # Aggregation with group by

# In[206]:


#cases and deaths sum and mean by country


# In[122]:


country_gby=covid.groupby(['countriesAndTerritories'])['cases','deaths']


# In[123]:


country_gby.agg(['sum','mean'])


# In[160]:


#icu occupancy and case testing sum by country


# In[266]:


icu_gby=covid.groupby(['country'])['value','population','new_cases','tests_done','testing_rate','positivity_rate']


# In[157]:


icu_gby.agg(['sum'])


# In[140]:


covid_dailycases=cases.groupby(['dateRep'])['cases','deaths','popData2020']


# In[141]:


covid_dailycases.agg(['sum'])


# #Calculating death percent

# In[143]:


covid['deathRate']=covid['deaths'].pct_change()


# In[144]:


covid['deathRate']


# # Getting the countries highest number of cases

# In[280]:


country_gby.max().reset_index()


# # Country with the highest cases 

# In[277]:


country_max = country_gby.sum().reset_index()


# In[279]:


country_max.max().reset_index()

