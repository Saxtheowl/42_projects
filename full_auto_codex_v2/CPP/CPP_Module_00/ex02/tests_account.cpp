#include "Account.hpp"

#include <cstdlib>
#include <iostream>

int main()
{
	Account acc1(100);
	Account acc2(200);

	Account::displayAccountsInfos();

	acc1.makeDeposit(50);
	acc2.makeWithdrawal(30);

	acc1.makeWithdrawal(1000); // should refuse

	acc1.displayStatus();
	acc2.displayStatus();

	Account::displayAccountsInfos();
	return EXIT_SUCCESS;
}
