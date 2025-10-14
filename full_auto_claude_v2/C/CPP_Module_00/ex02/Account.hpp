/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Account.hpp                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef ACCOUNT_HPP
# define ACCOUNT_HPP

class Account
{
public:
	typedef Account		t;

	static int	getNbAccounts();
	static int	getTotalAmount();
	static int	getNbDeposits();
	static int	getNbWithdrawals();
	static void	displayAccountsInfos();

	Account(int initial_deposit);
	~Account();

	void	makeDeposit(int deposit);
	bool	makeWithdrawal(int withdrawal);
	int		checkAmount() const;
	void	displayStatus() const;

private:
	static int	_nbAccounts;
	static int	_totalAmount;
	static int	_totalNbDeposits;
	static int	_totalNbWithdrawals;

	static void	_displayTimestamp();

	int	_accountIndex;
	int	_amount;
	int	_nbDeposits;
	int	_nbWithdrawals;

	Account();
};

#endif
