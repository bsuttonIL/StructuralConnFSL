function out_mat = connmtx_hagman2aparc(in_mat)
% function out_mat = connmtx_hagman2aparc(in_mat)
%  This function takes in a connectivity matrix that was calculated in
%  Hagmann order and outputs a martix in the standard aparc order.
%  This is useful for doing visualization with the connectome visualization
%  utility, which expects aparc order. 
%  Brad Sutton (bsutton@illinois.edu)

aparc_from_hag_ind = [31
13
9
21
27
3
25
19
29
34
15
23
1
24
4
30
11
26
6
2
5
22
16
14
10
20
12
7
8
18
32
17
28
33
65
47
43
55
61
37
59
53
63
68
49
57
35
58
38
64
45
60
40
36
39
56
50
48
44
54
46
41
42
52
66
51
62
67];


if ~(size(in_mat,1) == 68)
    sprintf('Expecting 68x68 connectivity matrix. row error')
    keyboard
end
if ~(size(in_mat,2) == 68)
    sprintf('Expecting 68x68 connectivity matrix. column error')
    keyboard
end

%reorder rows
out_mat = in_mat(aparc_from_hag_ind,:);
%reorder columns
out_mat = out_mat(:,aparc_from_hag_ind);


