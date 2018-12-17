% run the test function and compare 2.3 to 2.5 output for four test
% sites

clear
for i=1:4
    test_vslite_v2_5(i);
    print('-depsc',['test' num2str(i) 'fig.eps'])
    save('-mat',['test' num2str(i) 'work.mat'])
    [i]
    close
end
