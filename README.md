# UC-Widget
UCs are codes used in the Netherlands (for a fact, not sure about other countries) by supermarkets to tell the stock clerks when to remove a product from the store. It is basically the same as a date, but not meant to be understood by the average customer.

This widget is supposed to help stock clerks find out what today's UC is to make sure they remove the right products and not new ones.

UC stands for 'Uithaal Code' which translates to removal code which is self explanatory for what it's meant for.

The formats you can use that will be changed to current values are as follows:

{WEEK} The current week number.

{DAY_LETTER} The letter corresponding to the day number.

{DAY_NO} The number of the current day in the current week.

{YEAR} The full year.

{YEAR_SHORT} The last 2 digits of the current year.

{MONTH_NO} The number of the current month.

{MONTH_SHORT} The 3 letter abbreviated name of the current month.

{MONTH_LONG} The full name of the current month.

The default format is {WEEK}-{DAY_LETTER} which results in e.g. 36-D on 5 September.
