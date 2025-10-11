#include "Account.hpp"

#include <cstdlib>

int main()
{
    int amounts[] = {42, 54, 957, 432, 1234, 0, 754, 16576};
    int deposits[] = {5, 765, 564, 2, 87, 23, 9, 20};
    int withdrawals[] = {321, 34, 657, 4, 76, 0, 456, 123};

    const size_t nbAccounts = sizeof(amounts) / sizeof(int);
    Account accounts[] = {
        Account(amounts[0]), Account(amounts[1]), Account(amounts[2]),
        Account(amounts[3]), Account(amounts[4]), Account(amounts[5]),
        Account(amounts[6]), Account(amounts[7])
    };

    Account::displayAccountsInfos();
    for (size_t i = 0; i < nbAccounts; ++i)
        accounts[i].displayStatus();

    for (size_t i = 0; i < nbAccounts; ++i)
        accounts[i].makeDeposit(deposits[i]);

    Account::displayAccountsInfos();
    for (size_t i = 0; i < nbAccounts; ++i)
        accounts[i].displayStatus();

    for (size_t i = 0; i < nbAccounts; ++i)
        accounts[i].makeWithdrawal(withdrawals[i]);

    Account::displayAccountsInfos();
    for (size_t i = 0; i < nbAccounts; ++i)
        accounts[i].displayStatus();

    return EXIT_SUCCESS;
}
