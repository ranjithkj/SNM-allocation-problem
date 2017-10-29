include "globals.mzn";
% Problem Size

int: total_requests;
int: total_goods;
int: Seekers;
int: Donors;

% Declaration of seekers:

array[1..Seekers+1] of int: r_size;
array[1..Seekers] of float: priority_seekers;
array[1..total_requests] of int: requests_seekers;
array[1..Seekers] of set of int: set_request_seekers;
array[1..Seekers] of set of float: set_utility_requests;
array[1..total_requests] of float: utility_requests;

%array[1..total_requests] of int: P_1;
% Function which takes a request and a good as an input and outputs the preference utility 
function float: find_pref_good_wrt_request(int: r, int: g) = max(0,max([if preferred_goods[k] = g 
then P[k - p_size[r]] else 0.0 endif | k in p_size[r]+1..p_size[r+1]]));

% Function which takes a request as an input and outputs the preference utility of that request w.r.t seeker
function float: find_pref_request_wrt_seeker(int: r) = max(0,max([if requests_seekers[k] = r then P[k - r_size[find_seeker(r)]] else 0.0 endif| k in r_size[find_seeker(r)]+1..r_size[find_seeker(r)+1]]));

% Function which takes a request as an input and outputs the seeker
function int: find_seeker(int: r) = max(0,max([if r in set_request_seekers[i] then i else 0 endif | i in 1..Seekers]));


function float: f_1(int: k, int: i) = max(0,max([find_pref_good_wrt_request(j,k)| j in set_request_seekers[i]]));

function int: f_2(int: k, int: i) = max(0,max([if find_pref_good_wrt_request(j,k) != 0 then j else 0 endif|j in set_request_seekers[i]]));

% Declaration of Requests:

array[1..total_requests+1] of int: p_size;
array[1..max(p_size)] of int: preferred_goods;
array[1..total_requests] of set of int: set_preferred_goods;


% Goods:
set of int: goods = {i | i in 1..total_goods};
set of int: requests = {i | i in 1..total_requests};
array[1..Donors] of int: num_goods_per_donor;
array [1..10] of float: P = [1.0, 0.93, 0.80, 0.71, 0.6, 0.48, 0.39, 0.23, 0.11, 0.09];

% Decision Variables:
%array[1..total_requests,1..total_goods] of var bool: x;
array[1..total_requests] of var 0..total_goods: r;
%array[1..total_goods] of var 0..total_requests: g;
%array[1..Seekers] of var bool: T;



% Objective Function:
var int: s; 

/*predicate inverse_within_range(array[int] of var int: x1, array[int] of var int: x2) = 

   forall(i in index_set(x1)) (
     x1[i] <= total_goods /\ x1[i] != 0 <-> exists(j in index_set(x2)) (x2[j]  = i /\ x1[i] = j)
   )
   /\
   forall(j in index_set(x2)) (
     x2[j] <= total_requests /\ x2[j] != 0 <->  exists(i in index_set(x1)) (x1[i]  = j /\ x2[j] = i)
   )
;
*/

constraint 
    forall( i in 1..total_requests)
    (
        r[i] in 'union'(set_preferred_goods[i],{0})
    );
    
% 2. A good can be matched with only one request 
/*constraint 
   forall(j in 1..total_goods) 
 (
    g[j] in 'union'(requests,{0})
 );  
*/

/*constraint 
   forall(i in 1..total_requests)
   ( 
     if r[i] != 0 then
        g[r[i]] = i 
     else
        g[1] = g[1]
     endif   
   );
 */  
% 4. A constraint connecting r with binary variables x        

/*constraint 
   forall(i in 1..total_requests)  
   (
      forall(j in 1..total_goods)
      (
         if r[i] = j then 
            x[i,j] = 1 

         else
             x[i,j] = 0
         endif
       )
   );      
*/     
% 6. A constraint connecting g with binary variables x           
/*constraint 
   forall(i in 1..total_requests)  
   (
      forall(j in 1..total_goods)
      (
         if g[j] = i then 
            x[i,j] = 1 

         else
            x[i,j] = 0
         endif
       )
   );
*/  
/*constraint 
   forall( i in 1..total_requests)
   (
       if r[i] = 0 then
       forall(j in 1..total_goods) (x[i,j] = 0)
          
       else
       forall(j in 1..total_goods) (x[i,j] >= 0)
       
       endif   
   );
*/
% 8. 
/*constraint 
   forall( j in 1..total_goods )
   (
       if g[j] = 0 then
       forall(i in 1..total_requests) (x[i,j] = 0)
          
       else
       forall(i in 1..total_requests) (x[i,j] >= 0)
       
       endif   
   );     
*/               
                  
% 9. Constraint which enforces all requests to take different values                                                                                    
constraint alldifferent_except_0(r);    

% 10. Constraint which enforces all goods to take different values 
%constraint alldifferent_except_0(g);                 

%constraint inverse_within_range(r,g);
% 11. Envy-freeness for Seekers


constraint forall(i,j in 1..Seekers where i!= j)

(

sum(m in set_request_seekers[i], k in set_preferred_goods[m]) (find_pref_good_wrt_request(m,k) * element(m, r, k)) >= sum(m in set_request_seekers[j], k in set_preferred_goods[m]) ( f_1(k,i) * element(m, r, k) )

 
);

constraint global_cardinality(r,[0],[s]) ;

% 12. Envy-freeness for Requests
/*constraint forall(i,j in 1..total_requests where i != j)

(
   sum(k in set_preferred_goods[i]) ( find_pref_good_wrt_request(i,k) * x[i,k] ) >=sum(k in set_preferred_goods[j]) ( find_pref_good_wrt_request(i,k) * x[j,k] )
   
); */

/*
constraint forall(i in 1..Seekers)
(
    T[i] <= sum(k in set_request_seekers[i],j in 1..total_goods) (x[k,j])
);    


constraint forall(i in 1..Seekers)
(
   forall(k in set_request_seekers[i])
   (
      forall(j in 1..total_goods)
      (
         T[i] >= x[k,j]
      )
   )     
    
); */

%Proportional Fairness
constraint forall(i in 1..Seekers)

(
   sum(m in set_request_seekers[i], k in set_preferred_goods[m]) (find_pref_good_wrt_request(m,k) * bool2int(r[m] == k) ) >= sum(m in set_request_seekers[i], k in set_preferred_goods[m]) (find_pref_good_wrt_request(m,k)/card(set_preferred_goods[m]))/Seekers

);


% Objective function   


% Maximizing cardinality of satisfied requests
%s = sum(i in 1..total_requests,j in 1..total_goods) (find_pref_good_wrt_request(i,j) * (bool2int(r[i] == j))) ;
%s = sum(i in 1..total_requests,j in 1..total_goods) (find_pref_good_wrt_request(i,j) * x[i,j] ) ;
%s = sum(i in 1..total_requests,j in 1..total_goods) ((priority_seekers[find_seeker(i)] * find_pref_request_wrt_seeker(i) * find_pref_good_wrt_request(i,j))* x[i,j]);
% Maximizing sum of preference_matrix and utility over satisfied requests                           


solve minimize s;

%output ["\(s)"];

