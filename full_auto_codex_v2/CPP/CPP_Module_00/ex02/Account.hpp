#pragma once

#include <iostream>

class Account
{
public:
	typedef Account t;

	static int getNbAccounts();
	static int getTotalAmount();
	static int getNbDeposits();
	static int getNbWithdrawals();
	static void displayAccountsInfos();

	Account(int initial_deposit);
	~Account();

	void makeDeposit(int deposit);
	bool makeWithdrawal(int withdrawal);
	void displayStatus() const;

private:
	static int _nbAccounts;
	static int _totalAmount;
	static int _totalNbDeposits;
	static int _totalNbWithdrawals;

	static void _displayTimestamp();

	int _accountIndex;
	int _amount;
	int _nbDeposits;
	int _nbWithdrawals;
};
