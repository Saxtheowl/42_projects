/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   irc.hpp                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef IRC_HPP
# define IRC_HPP

# include <iostream>
# include <string>
# include <vector>
# include <map>
# include <set>
# include <sstream>
# include <cstring>
# include <cstdlib>
# include <cerrno>
# include <unistd.h>
# include <fcntl.h>
# include <netinet/in.h>
# include <arpa/inet.h>
# include <sys/socket.h>
# include <sys/select.h>
# include <signal.h>

# define BUFFER_SIZE 512
# define MAX_CLIENTS 100

class Client;
class Channel;
class Server;

/* IRC Reply codes */
# define RPL_WELCOME		"001"
# define RPL_YOURHOST		"002"
# define RPL_CREATED		"003"
# define RPL_MYINFO			"004"
# define RPL_CHANNELMODEIS	"324"
# define RPL_NOTOPIC		"331"
# define RPL_TOPIC			"332"
# define RPL_INVITING		"341"
# define RPL_NAMREPLY		"353"
# define RPL_ENDOFNAMES		"366"

/* IRC Error codes */
# define ERR_NOSUCHNICK		"401"
# define ERR_NOSUCHCHANNEL	"403"
# define ERR_CANNOTSENDTOCHAN "404"
# define ERR_TOOMANYCHANNELS	"405"
# define ERR_UNKNOWNCOMMAND	"421"
# define ERR_NONICKNAMEGIVEN	"431"
# define ERR_ERRONEUSNICKNAME	"432"
# define ERR_NICKNAMEINUSE	"433"
# define ERR_USERNOTINCHANNEL	"441"
# define ERR_NOTONCHANNEL	"442"
# define ERR_USERONCHANNEL	"443"
# define ERR_NOTREGISTERED	"451"
# define ERR_NEEDMOREPARAMS	"461"
# define ERR_ALREADYREGISTERED	"462"
# define ERR_PASSWDMISMATCH	"464"
# define ERR_CHANNELISFULL	"471"
# define ERR_INVITEONLYCHAN	"473"
# define ERR_BADCHANNELKEY	"475"
# define ERR_CHANOPRIVSNEEDED	"482"

#endif
