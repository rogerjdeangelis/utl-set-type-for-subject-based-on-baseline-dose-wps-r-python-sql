%let pgm=utl-set-type-for-subject-based-on-baseline-dose-wps-r-python-sql;


Problem
    if baseline dose by patient <= 8mg  then treatment = A else treatment = B

 SOLUTIONS

     1  wps no sql
     2  wps sql
     3  wps r no sql
     4  wps r sql
     5  wps python sql


githib
https://tinyurl.com/5fvr83fx
https://github.com/rogerjdeangelis/utl-set-type-for-subject-based-on-baseline-dose-wps-r-python-sql

stackoverflow
https://tinyurl.com/4mvvxtpe
https://stackoverflow.com/questions/77173385/how-to-create-a-column-that-creates-a-value-for-multiple-rows-based-on-other-val


/**************************************************************************************************************************/
/*                                   |                          |                                                         */
/*               INPUT               |      PROCESS             |               OUTPUT                                    */
/*                                   |                          |                                                         */
/*  PATIENT     DATE      DOSE  TYPE |                          |   PATIENT     DATE      DOSE  TYPE                      */
/*                                   |                          |                                                         */
/*     1      08JUN2011     7    A   |  first dose <=8 then "A" |      1      08JUN2011     7    A                        */
/*     1      03OCT2011    10    A   |  apply to patient 1      |      1      03OCT2011    10    A                        */
/*     1      06JUL2015     9    A   |                          |      1      06JUL2015     9    A                        */
/*                                   |                          |                                                         */
/*     2      22DEC2011     9    B   |  first dose > 8 then "B" |      2      22DEC2011     9    B                        */
/*     2      01JAN2012     8    B   |  apply to patient e      |      2      01JAN2012     8    B                        */
/*     2      21NOV2017     7    B   |                          |      2      21NOV2017     7    B                        */
/*     3      23JUN2011    10    B   |                          |      3      23JUN2011    10    B                        */
/*     3      12JUL2014     6    B   |                          |      3      12JUL2014     6    B                        */
/*     3      17JUN2018     8    B   |                          |      3      17JUN2018     8    B                        */
/*                                   |                          |                                                         */
/*     4      16JUL2013     8    A   |                          |      4      16JUL2013     8    A                        */
/*     4      15JUN2014    10    A   |                          |      4      15JUN2014    10    A                        */
/*     4      21APR2015     5    A   |                          |      4      21APR2015     5    A                        */
/*                                   |                          |                                                         */
/*     5      09MAR2010    10    B   |                          |      5      09MAR2010    10    B                        */
/*     5      03JAN2012    12    B   |                          |      5      03JAN2012    12    B                        */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

options validvarname=upcase;
data sd1.have;
   informat date date9.;
   format date date9.;
   input patient date dose;
cards4;
1 08JUN2011 7
1 06JUL2015 9
1 03OCT2011 10
2 01JAN2012 8
2 21NOV2017 7
2 22DEC2011 9
3 23JUN2011 10
3 17JUN2018 8
3 12JUL2014 6
4 21APR2015 5
4 16JUL2013 8
4 15JUN2014 10
5 17MAY2014 15
5 03JAN2012 12
5 09MAR2010 10
;;;;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  SD1.HAVE total obs=15                                                                                                 */
/*                                                                                                                        */
/*  Obs     DATE    PATIENT    DOSE                                                                                       */
/*                                                                                                                        */
/*    1    18786       1         7                                                                                        */
/*    2    20275       1         9                                                                                        */
/*    3    18903       1        10                                                                                        */
/*    4    18993       2         8                                                                                        */
/*    5    21144       2         7                                                                                        */
/*    6    18983       2         9                                                                                        */
/*    7    18801       3        10                                                                                        */
/*    8    21352       3         8                                                                                        */
/*    9    19916       3         6                                                                                        */
/*   10    20199       4         5                                                                                        */
/*   11    19555       4         8                                                                                        */
/*   12    19889       4        10                                                                                        */
/*   13    19860       5        15                                                                                        */
/*   14    18995       5        12                                                                                        */
/*   15    18330       5        10                                                                                        */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*                                                _
/ | __      ___ __  ___   _ __   ___    ___  __ _| |
| | \ \ /\ / / `_ \/ __| | `_ \ / _ \  / __|/ _` | |
| |  \ V  V /| |_) \__ \ | | | | (_) | \__ \ (_| | |
|_|   \_/\_/ | .__/|___/ |_| |_|\___/  |___/\__, |_|
             |_|                               |_|
*/

proc datasets lib=sd1 nolist nodetails;delete want; run;quit;

%utl_submit_wps64x('

libname sd1 "d:/sd1";

proc sort data=sd1.have out=have;
  by patient date;
run;quit;

data sd1.want;
  retain baseline_med " ";
  set have;
  by patient date;
  treatment = ifc(first.patient and dose<=8,"A","B");
run;quit;

proc print;
run;quit;
');

/*___                                   _
|___ \  __      ___ __  ___   ___  __ _| |
  __) | \ \ /\ / / `_ \/ __| / __|/ _` | |
 / __/   \ V  V /| |_) \__ \ \__ \ (_| | |
|_____|   \_/\_/ | .__/|___/ |___/\__, |_|
                 |_|                 |_|
*/

proc datasets lib=sd1 nolist nodetails;delete want; run;quit;

%utl_submit_wps64x('

libname sd1 "d:/sd1";

options validvarname=any;

proc sql;
  create
    table sd1.want as
  select
    l.patient
   ,l.date
   ,l.dose
   ,r.treatment
  from
    sd1.have as l left join (
      select
         patient
        ,case
           when dose <=8 then "A"
           else "B"
         end as treatment
      from
         sd1.have
      group
         by patient
      having
         date = min(date)
      ) as r
   on
      l.patient = r.patient
;quit;

proc print;
run;quit;
');


/**************************************************************************************************************************/
/*                                                                                                                        */
/* WORK.WANT total obs=15                                                                                                 */
/*                                                                                                                        */
/* Obs    PATIENT     DATE    DOSE  TREATMENT                                                                             */
/*                                                                                                                        */
/*   1       1       20275      9      A                                                                                  */
/*   2       1       18903     10      A                                                                                  */
/*   3       1       18786      7      A                                                                                  */
/*   4       2       18983      9      B                                                                                  */
/*   5       2       21144      7      B                                                                                  */
/*   6       2       18993      8      B                                                                                  */
/*   7       3       18801     10      B                                                                                  */
/*   8       3       19916      6      B                                                                                  */
/*   9       3       21352      8      B                                                                                  */
/*  10       4       19889     10      A                                                                                  */
/*  11       4       19555      8      A                                                                                  */
/*  12       4       20199      5      A                                                                                  */
/*  13       5       18330     10      B                                                                                  */
/*  14       5       18995     12      B                                                                                  */
/*  15       5       19860     15      B                                                                                  */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*____                                                       _
|___ /  __      ___ __  ___   _ __   _ __   ___    ___  __ _| |
  |_ \  \ \ /\ / / `_ \/ __| | `__| | `_ \ / _ \  / __|/ _` | |
 ___) |  \ V  V /| |_) \__ \ | |    | | | | (_) | \__ \ (_| | |
|____/    \_/\_/ | .__/|___/ |_|    |_| |_|\___/  |___/\__, |_|
                 |_|                                      |_|
*/

proc datasets lib=sd1 nolist nodetails;delete want; run;quit;

options ls=255 ps=65;

%utl_submit_wps64x('
libname sd1 "d:/sd1";
proc r;
export data=sd1.have r=have;
submit;
library(dplyr);
library(tidyr);
want <- have %>%
  group_by(PATIENT) %>%
  mutate(treatment = case_when(
    DATE == min(DATE) & DOSE <= 8 ~ "A",
    DATE == min(DATE) & DOSE > 8 ~ "B",
    TRUE ~ NA
  )) %>%
  fill(treatment, .direction = "updown") %>%
  ungroup();
want;
endsubmit;
import data=sd1.want r=want;
proc print data=sd1.want;
run;quit;
');

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  R                                                                                                                     */
/*                                                                                                                        */
/*  # A tibble: 15 x 4                                                                                                    */
/*     DATE       PATIENT  DOSE baseline_med                                                                              */
/*                                                                                                                        */
/*     <date>       <dbl> <dbl> <chr>                                                                                     */
/*   1 2011-06-08       1     7 A                                                                                         */
/*   2 2015-07-06       1     9 A                                                                                         */
/*   3 2011-10-03       1    10 A                                                                                         */
/*   4 2012-01-01       2     8 B                                                                                         */
/*   5 2017-11-21       2     7 B                                                                                         */
/*   6 2011-12-22       2     9 B                                                                                         */
/*   7 2011-06-23       3    10 B                                                                                         */
/*   8 2018-06-17       3     8 B                                                                                         */
/*   9 2014-07-12       3     6 B                                                                                         */
/*  10 2015-04-21       4     5 A                                                                                         */
/*  11 2013-07-16       4     8 A                                                                                         */
/*  12 2014-06-15       4    10 A                                                                                         */
/*  13 2014-05-17       5    15 B                                                                                         */
/*  14 2012-01-03       5    12 B                                                                                         */
/*  15 2010-03-09       5    10 B                                                                                         */
/*                                                                                                                        */
/* WPS                                                                                                                    */
/*                                                                                                                        */
/*  Obs         DATE    PATIENT    DOSE     TREATMENT                                                                     */
/*                                                                                                                        */
/*    1    08JUN2011       1         7          A                                                                         */
/*    2    06JUL2015       1         9          A                                                                         */
/*    3    03OCT2011       1        10          A                                                                         */
/*    4    01JAN2012       2         8          B                                                                         */
/*    5    21NOV2017       2         7          B                                                                         */
/*    6    22DEC2011       2         9          B                                                                         */
/*    7    23JUN2011       3        10          B                                                                         */
/*    8    17JUN2018       3         8          B                                                                         */
/*    9    12JUL2014       3         6          B                                                                         */
/*   10    21APR2015       4         5          A                                                                         */
/*   11    16JUL2013       4         8          A                                                                         */
/*   12    15JUN2014       4        10          A                                                                         */
/*   13    17MAY2014       5        15          B                                                                         */
/*   14    03JAN2012       5        12          B                                                                         */
/*   15    09MAR2010       5        10          B                                                                         */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*  _                                           _
| || |   __      ___ __  ___   _ __   ___  __ _| |
| || |_  \ \ /\ / / `_ \/ __| | `__| / __|/ _` | |
|__   _|  \ V  V /| |_) \__ \ | |    \__ \ (_| | |
   |_|     \_/\_/ | .__/|___/ |_|    |___/\__, |_|
                  |_|                        |_|
*/
proc datasets lib=sd1 nolist nodetails;delete want; run;quit;

options ls=255 ps=65;

%utl_submit_wps64x('
libname sd1 "d:/sd1";
proc r;
export data=sd1.have r=have;
submit;
library(sqldf);
want<-sqldf("
  select
    l.patient
   ,l.date
   ,l.dose
   ,r.treatment
  from
    have as l left join (
      select
         patient
        ,case
           when dose <=8 then \"A\"
           else \"B\"
         end as treatment
      from
         have
      group
         by patient
      having
         date = min(date)
      ) as r
   on
      l.patient = r.patient
");
want;
endsubmit;
');

/*___                                     _   _                             _
| ___|  __      ___ __  ___   _ __  _   _| |_| |__   ___  _ __    ___  __ _| |
|___ \  \ \ /\ / / `_ \/ __| | `_ \| | | | __| `_ \ / _ \| `_ \  / __|/ _` | |
 ___) |  \ V  V /| |_) \__ \ | |_) | |_| | |_| | | | (_) | | | | \__ \ (_| | |
|____/    \_/\_/ | .__/|___/ | .__/ \__, |\__|_| |_|\___/|_| |_| |___/\__, |_|
                 |_|         |_|    |___/                                |_|
*/

%utl_submit_wps64x("
options validvarname=any lrecl=32756;
libname sd1 'd:/sd1';
proc sql;select max(cnt) into :_cnt from (select count(nam) as cnt from sd1.have group by nam);quit;
%array(_unq,values=1-&_cnt);
proc python;
export data=sd1.have python=have;
submit;
print(have);
from os import path;
import pandas as pd;
import numpy as np;
import pandas as pd;
from pandasql import sqldf;
mysql = lambda q: sqldf(q, globals());
from pandasql import PandaSQL;
pdsql = PandaSQL(persist=True);
sqlite3conn = next(pdsql.conn.gen).connection.connection;
sqlite3conn.enable_load_extension(True);
sqlite3conn.load_extension('c:/temp/libsqlitefunctions.dll');
mysql = lambda q: sqldf(q, globals());
want = pdsql('''
  select
    l.patient
   ,l.date
   ,l.dose
   ,r.treatment
  from
    have as l left join (
      select
         patient
        ,case
           when dose <=8 then `A`
           else `B`
         end as TREATMENT
      from
         have
      group
         by patient
      having
         date = min(date)
      ) as r
   on
      l.patient = r.patient
''');
print(want);
endsubmit;
import data=sd1.want python=want;
proc print data=sd1.want;
run;quit;
");

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  PYTHON                                                                                                                */
/*                                                                                                                        */
/*      PATIENT                        DATE  DOSE TREATMENT                                                               */
/*  0       1.0  2011-06-08 00:00:00.000000   7.0         A                                                               */
/*  1       1.0  2015-07-06 00:00:00.000000   9.0         A                                                               */
/*  2       1.0  2011-10-03 00:00:00.000000  10.0         A                                                               */
/*  3       2.0  2012-01-01 00:00:00.000000   8.0         B                                                               */
/*  4       2.0  2017-11-21 00:00:00.000000   7.0         B                                                               */
/*  5       2.0  2011-12-22 00:00:00.000000   9.0         B                                                               */
/*  6       3.0  2011-06-23 00:00:00.000000  10.0         B                                                               */
/*  7       3.0  2018-06-17 00:00:00.000000   8.0         B                                                               */
/*  8       3.0  2014-07-12 00:00:00.000000   6.0         B                                                               */
/*  9       4.0  2015-04-21 00:00:00.000000   5.0         A                                                               */
/*  10      4.0  2013-07-16 00:00:00.000000   8.0         A                                                               */
/*  11      4.0  2014-06-15 00:00:00.000000  10.0         A                                                               */
/*  12      5.0  2014-05-17 00:00:00.000000  15.0         B                                                               */
/*  13      5.0  2012-01-03 00:00:00.000000  12.0         B                                                               */
/*  14      5.0  2010-03-09 00:00:00.000000  10.0         B                                                               */
/*                                                                                                                        */
/* WPS                                                                                                                    */
/*                                                                                                                        */
/* WPS  (NOT SURE WHY PYTON CHANGES DATE TO CHARACTER)                                                                    */
/*                                                                                                                        */
/* Obs    PATIENT               DATE               DOSE    TREATMENT                                                      */
/*                                                                                                                        */
/*   1       1       2011-06-08 00:00:00.000000      7         A                                                          */
/*   2       1       2015-07-06 00:00:00.000000      9         A                                                          */
/*   3       1       2011-10-03 00:00:00.000000     10         A                                                          */
/*   4       2       2012-01-01 00:00:00.000000      8         B                                                          */
/*   5       2       2017-11-21 00:00:00.000000      7         B                                                          */
/*   6       2       2011-12-22 00:00:00.000000      9         B                                                          */
/*   7       3       2011-06-23 00:00:00.000000     10         B                                                          */
/*   8       3       2018-06-17 00:00:00.000000      8         B                                                          */
/*   9       3       2014-07-12 00:00:00.000000      6         B                                                          */
/*  10       4       2015-04-21 00:00:00.000000      5         A                                                          */
/*  11       4       2013-07-16 00:00:00.000000      8         A                                                          */
/*  12       4       2014-06-15 00:00:00.000000     10         A                                                          */
/*  13       5       2014-05-17 00:00:00.000000     15         B                                                          */
/*  14       5       2012-01-03 00:00:00.000000     12         B                                                          */
/*  15       5       2010-03-09 00:00:00.000000     10         B                                                          */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
