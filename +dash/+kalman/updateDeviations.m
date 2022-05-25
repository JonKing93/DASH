function[Xdev] = updateDeviations(Xdev, a, K, Ydev)

Xdev = Xdev - a * K * Ydev;

end