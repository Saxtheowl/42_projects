#ifndef ACCOUNT_HPP
#define ACCOUNT_HPP

#include <iostream>

class Account
{
public:
    typedef Account t;

private:
    static int  _nbAccounts;
    static int  _totalAmount;
    static int  _totalNbDeposits;
    static int  _totalNbWithdrawals;

    int         _accountIndex;
    int         _amount;
    int         _nbDeposits;
    int         _nbWithdrawals;

    static void _displayTimestamp();

public:
    Account(int initial_deposit);
    ~Account();

    void    makeDeposit(int deposit);
    bool    makeWithdrawal(int withdrawal);
    int     checkAmount() const;
    void    displayStatus() const;

    static int  getNbAccounts();
    static int  getTotalAmount();
    static int  getNbDeposits();
    static int  getNbWithdrawals();
    static void displayAccountsInfos();
};

#endif
