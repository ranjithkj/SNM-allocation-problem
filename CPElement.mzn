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
array[1..total_requests,1..total_goods+1] of int: w;

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
array [1..10] of float: P = [0, 5, 3, 2, 0.71, 0.6, 0.48, 0.39, 0.23, 0.11]; 

% Decision Variables:
%array[1..total_requests,1..total_goods] of var bool: x;
array[1..total_requests] of var 0..total_goods: r;
array[1..Seekers,1..total_goods+1] of var 0..total_goods: u;
%array[1..Seekers,1..total_goods] of var 0..total_goods: w;

%array[1..total_goods] of var 0..total_requests: g;
%array[1..Seekers] of var bool: T;

% Objective Function:
var int: s; 

% Constraint 1
constraint 
    forall( i in 1..total_requests)
    (
        r[i] in 'union'(set_preferred_goods[i],{0})
    );
    
% Constraint 2 which enforces all requests to take different values                                                                                    
constraint alldifferent_except_0(r);    



% Constraint 3 -> Connecting weight values to seeker values:

constraint forall(s in 1..Seekers)

( 

forall(i in set_request_seekers[s])

( 
   element(r[i]+1, [u[s,g] | g in 1..total_goods+1], w[i,r[i]+1]) 
)

);



% Constraint 4 -> Helping us with the objective function
constraint global_cardinality(r,[0],[s]) ;

%Constraint 5 -> Proportional Fairness
/*constraint forall(i in 1..Seekers)

(
   sum(m in set_request_seekers[i], k in set_preferred_goods[m]) (find_pref_good_wrt_request(m,k) * bool2int(r[m] == k) ) >= sum(m in set_request_seekers[i], k in set_preferred_goods[m]) (find_pref_good_wrt_request(m,k)/card(set_preferred_goods[m]))/Seekers

);*/


% constraint 5 -> envy-freeness using cp:

constraint forall(s,t in 1..Seekers where s!= t)

(

sum(i in set_request_seekers[s]) (u[ s, r[i] ]) >= sum(j in set_request_seekers[t]) (u[ s, r[j] ])

);

%constraint alldifferent(w);

    
% Objective function   
solve minimize s;

%output ["\(w)"];