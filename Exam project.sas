/* Exam Project */

*import the data;

options validvarname=v7;
/* creating the macro variable for both type A and B to cut my original code in half */
/* Using macro variable for type A and B to simplfy the code */
%let type = A;
proc import datafile = "/home/u45036707/Files/Form&type..csv"
			out = Form&type
			dbms= csv
			replace;			
run;

proc import datafile = "/home/u45036707/Files/Domains Form&type..csv"
			out = Domain&type
			dbms = csv
			replace;
run;

/* part 1 */
/* Creating a Table to display the form A whether the student get questions right or wrong. Score "1" is right, "0" is wrong. */
data result&type;
	set Form&type;
	
	array tests(150) $ Q1-Q150;
	array answerKey (*) $ K1-K150;
	
	Form = "&type";
	
	retain K1-K150;
	If Student = "&type.&type.&type.&type.KEY" then do i = 1 to 150;
		answerKey(i) = tests(i);
		
	end;
	else do Questions = 1 to 150;
		if answerKey(Questions) = tests(Questions) then Score = 1;
		else Score = 0;
		output;
	end;
	
	keep student Score Questions Form;
run;


/* Part 2 */
/* Merge the table with FormA and DomainA	 */
proc sql;
create table joined&type as
	select Form,student,result&type..Questions,Score,DomainNum
	from result&type inner join Domain&type
	on result&type..Questions = Domain&type..QuestionNum;
quit;

/* Part 3 */;
/* Combine the two tables for Forms A and B created in step 2; */
/* Convert Student type from char to numeric */
data table_combined;
	set joinedA joinedB;
	Students = input(Student,8.);
	drop Student;
	rename Students = Student;
run;

/* Part 4 */
/* Totalscore and percent for each student, and five domains  */
proc means data = table_combined sum mean noprint;
	var Score;
	class Student DomainNum;
	id Form;
	output out = Score_mean (drop=_TYPE_ _FREQ_) mean=percentage sum=totalscore;
run;

/* proc print data=Score_mean; */
/* run; */

/* Part 5 */
/* sort the table by students */
proc sort data=Score_mean;
	by Student;
	where Student is not missing;
	format percentage 8.5;
run;

/* Part 6 */
data Students_combined;
	set Score_mean;
	
	array Score_domain(*) OP OS DP1 DS1 DP2 DS2 DP3 DS3 DP4 DS4 DP5 DS5;
	retain OP OS DP1 DS1 DP2 DS2 DP3 DS3 DP4 DS4 DP5 DS5;
	
	by Student;
	
	if first.Student then i = 0;
	i+1;
	Score_domain(i) = percentage;
	i+1;
	Score_domain(i) = totalscore;
	
	if last.Student then output;
	
	label OP = "Overall Percentage"
		  OS = "Overall Score"
		  DP1 = "Domain 1 Percentage"
		  DS1 = "Domain 1 Score"
		  DP2 = "Domain 2 Percentage"
		  DS2 = "Domain 2 Score"
		  DP3 = "Domain 3 Percentage"
		  DS3 = "Domain 3 Score"
		  DP4 = "Domain 4 Percentage"
		  DS4 = "Domain 4 Score"
		  DP5 = "Domain 5 Percentage"
		  DS5 = "Domain 5 Score";
	drop i DomainNum percentage totalscore;
	format DP1-DP5 percent7.2 OP percent7.2;
	
run;

/* proc print data = Students_combined label; */
/* 	var Student Form OS OP DS1 DP1 DS2 DP2 DS3 DP3 DS4 DP4 DS5 DP5; */
/* 	 */
/* run; */
	
/* Part 7 */
/* side-by-side boxplots of give domains using student percentages as the response */
title "Boxplots of Student Percentage for Five Domains";
proc sgplot data=Score_mean;
	vbox percentage/category=DomainNum;
	xaxis label="Domain";
	yaxis label="Student Percentage";
	format Student Percentage PERCENT8.1;
run;
title;

/* Part 8 */
/* Percentage correct for each question in separated form */
proc means data=table_combined mean nonobs noprint;
	var Score;
	class Form Questions;
	id Student;
	ways 2;
	output out = percentOnQuestions (drop= _TYPE_ _FREQ_) mean=QuestionPercent;
	
run;
/*  */
/* title "Percent correct for each question"; */
/* proc print data=percentOnQuestions; */
/* 	var Form Questions QuestionPercent; */
/* 	format QuestionPercent 4.2; */
/* run; */
/* title; */

/* Part 9 */
/* create PDF file */
ods pdf file= "~/124_Assignments/Final_Project.pdf";
options nodate nonumber orientation=landscape;

/* Section A */
*Table sorted by stduentID;
title "Section A - Student Scores";	
title2 "Sorted by Student ID";
proc print data = Students_combined label noobs;
	var Student Form OS OP DS1 DS2 DS3 DS4 DS5 DP1 DP2 DP3 DP4 DP5;
	
run;
title;

*Table sorted by overall percentage;
proc sort data=Students_combined out= combined_sorted;
	by descending OS;
run;

title "Section A - Student Scores";	
title2 "Sorted Highest to Lowest Overall Score";
proc print data=combined_sorted label noobs;
	var Student Form OP OS DP1 DP2 DP3 DP4 DP5 DS1 DS2 DS3 DS4 DS5;
run;
title;

*side-by-side boxplot;
title "Section A - Student Scores";
title2 "Boxplots of Student Percentage for Five Domains";
proc sgplot data=Score_mean;
	vbox percentage/category=DomainNum;
	xaxis label="Domain";
	yaxis label="Student Percentage";
	format Student Percentage PERCENT8.1;
run;
title;

/* Section B */
*table sorted by exam form then by question number;
title "Section B: Question Analysis";
title2 "Sorted by Exam Form and Question Number";
proc print data=percentOnQuestions noobs;
	var Form Questions QuestionPercent;
	format QuestionPercent percent8.1;
run;
title;

*table sorted by question percentage;
proc sort data=percentOnQuestions out=sorted_percentOnQuestions;
	by descending QuestionPercent;
	format QuestionPercent percent8.1;
run;

title "Section B: Question Analysis";
title2 "Sorted by Question Percentage";
proc print data = sorted_percentOnQuestions;
	var QuestionPercent Form Questions;
run;
title;

ods pdf close;












	
	
