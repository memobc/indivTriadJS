function Calculate_Dependency(x)
% Calculate Dependency Using Bisby 2018 Script

% extract meta data from filename
subj = cellstr(regexp(x, '(?<=sub-).*(?=_sess)', 'match', 'once'));
sess = cellstr(regexp(x, '(?<=sess-).*(?=_)', 'match', 'once'));
cond = cellstr(regexp(x, '(?<=cond-).*(?=\.csv)', 'match', 'once'));

% load table into matlab
opts = detectImportOptions(x);
opts = setvartype(opts,'logical');
A = readtable(x, opts);

% convert to double array
A = table2array(A);
A = double(A);

% Ab Ac
out          = Dependency(A, [3,4]);
Data_Ab_Ac   = out(1);
Indep_Ab_Ac  = out(2);
Depend_Ab_Ac = out(3);

% Ba Bc
out          = Dependency(A, [5,6]);
Data_Ba_Bc   = out(1);
Indep_Ba_Bc  = out(2);
Depend_Ba_Bc = out(3);


% Ca Cb
out          = Dependency(A, [1,2]);
Data_Ca_Cb   = out(1);
Indep_Ca_Cb  = out(2);
Depend_Ca_Cb = out(3);

% Ba Ca
out          = Dependency(A, [6,2]);
Data_Ba_Ca   = out(1);
Indep_Ba_Ca  = out(2);
Depend_Ba_Ca = out(3);

% Ab Cb
out          = Dependency(A, [3,1]);
Data_Ab_Cb   = out(1);
Indep_Ab_Cb  = out(2);
Depend_Ab_Cb = out(3);

% Ac Bc
out          = Dependency(A, [4,5]);
Data_Ca_Bc   = out(1);
Indep_Ac_Bc  = out(2);
Depend_Ac_Bc = out(3);

% organize into a table
C = table(subj, sess, cond, ...
          Data_Ab_Ac, Data_Ba_Bc, Data_Ca_Cb, Data_Ba_Ca, Data_Ab_Cb, Data_Ca_Bc, ...
          Indep_Ab_Ac, Indep_Ba_Bc, Indep_Ca_Cb, Indep_Ba_Ca, Indep_Ab_Cb, Indep_Ac_Bc, ...
          Depend_Ab_Ac, Depend_Ba_Bc,Depend_Ca_Cb,Depend_Ba_Ca,Depend_Ab_Cb,Depend_Ac_Bc);

% write out in the same directory, appending "dependency_" to the filename
[x,y,z] = fileparts(x);
y = ['dependency_' y];
writetable(C, fullfile(x, [y z]))

end
