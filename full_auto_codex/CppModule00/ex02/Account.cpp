#include "Account.hpp"

#include <ctime>
#include <iomanip>

int Account::_nbAccounts = 0;
int Account::_totalAmount = 0;
int Account::_totalNbDeposits = 0;
int Account::_totalNbWithdrawals = 0;

static void printTimestamp()
{
    std::time_t now = std::time(NULL);
    std::tm *lt = std::localtime(&now);
    std::cout << "[" << std::setfill('0') << std::setw(4) << (lt->tm_year + 1900)
              << std::setw(2) << (lt->tm_mon + 1) << std::setw(2) << lt->tm_mday
              << "_" << std::setw(2) << lt->tm_hour << std::setw(2) << lt->tm_min
              << std::setw(2) << lt->tm_sec << "] ";
    std::cout << std::setfill(' ');
}

void Account::_displayTimestamp()
{
    printTimestamp();
}

Account::Account(int initial_deposit)
    : _accountIndex(_nbAccounts),
      _amount(initial_deposit),
      _nbDeposits(0),
      _nbWithdrawals(0)
{
    ++_nbAccounts;
    _totalAmount += initial_deposit;
    _displayTimestamp();
    std::cout << "index:" << _accountIndex << ";amount:" << _amount << ";created"
              << std::endl;
}

Account::~Account()
{
    _displayTimestamp();
    std::cout << "index:" << _accountIndex << ";amount:" << _amount << ";closed"
              << std::endl;
}

int Account::getNbAccounts()
{
    return _nbAccounts;
}

int Account::getTotalAmount()
{
    return _totalAmount;
}

int Account::getNbDeposits()
{
    return _totalNbDeposits;
}

int Account::getNbWithdrawals()
{
    return _totalNbWithdrawals;
}

void Account::displayAccountsInfos()
{
    _displayTimestamp();
    std::cout << "accounts:" << getNbAccounts() << ";total:" << getTotalAmount()
              << ";deposits:" << getNbDeposits() << ";withdrawals:"<< getNbWithdrawals()
              << std::endl;
}

void Account::makeDeposit(int deposit)
{
    int previous = _amount;
    _amount += deposit;
    ++_nbDeposits;
    ++_totalNbDeposits;
    _totalAmount += deposit;
    _displayTimestamp();
    std::cout << "index:" << _accountIndex << ";p_amount:" << previous
              << ";deposit:" << deposit << ";amount:" << _amount
              << ";deposits:" << _nbDeposits << std::endl;
}

bool Account::makeWithdrawal(int withdrawal)
{
    int previous = _amount;
    _displayTimestamp();
    std::cout << "index:" << _accountIndex << ";p_amount:" << previous << ";withdrawal:";
    if (withdrawal > _amount)
    {
        std::cout << "refused" << std::endl;
        return false;
    }
    _amount -= withdrawal;
    ++_nbWithdrawals;
    ++_totalNbWithdrawals;
    _totalAmount -= withdrawal;
    std::cout << withdrawal << ";amount:" << _amount << ";withdrawals:" << _nbWithdrawals
              << std::endl;
    return true;
}

int Account::checkAmount() const
{
    return _amount;
}

void Account::displayStatus() const
{
    _displayTimestamp();
    std::cout << "index:" << _accountIndex << ";amount:" << _amount << ";deposits:"
              << _nbDeposits << ";withdrawals:" << _nbWithdrawals << std::endl;
}
