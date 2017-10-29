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
array[1..total_requests,1..total_goods] of int: w;

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
array[1..Seekers,1..total_goods] of var 0..1: u;
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

% Constraint 3 -> Envy-freeness
constraint forall(i,j in 1..Seekers where i!= j)

(

sum(m in set_request_seekers[i], k in set_preferred_goods[m]) (find_pref_good_wrt_request(m,k) * (r[i] == j)) >= sum(m in set_request_seekers[j], k in set_preferred_goods[m]) ( f_1(k,i) * (r[i] == j) )

);

% Constraint 3 -> Envy-freeness

% Constraint 4 -> Helping us with the objective function
constraint global_cardinality(r,[0],[s]) ;

%Constraint 5 -> Proportional Fairness
/*constraint forall(i in 1..Seekers)

(
   sum(m in set_request_seekers[i], k in set_preferred_goods[m]) (find_pref_good_wrt_request(m,k) * bool2int(r[m] == k) ) >= sum(m in set_request_seekers[i], k in set_preferred_goods[m]) (find_pref_good_wrt_request(m,k)/card(set_preferred_goods[m]))/Seekers

);*/


%constraint alldifferent(w);

    
% Objective function   
solve minimize P[r[1]];

output ["\(P[r[1]])"];