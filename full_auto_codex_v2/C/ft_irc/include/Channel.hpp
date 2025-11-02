#pragma once

#include <set>
#include <string>

struct Channel
{
	std::string name;
	std::string topic;
	std::string key;
	bool inviteOnly;
	bool topicProtected;
	size_t userLimit;
	std::set<int> members;
	std::set<int> operators;
	std::set<int> invited;

	Channel()
		: name(),
		  topic(),
		  key(),
		  inviteOnly(false),
		  topicProtected(false),
		  userLimit(0),
		  members(),
		  operators(),
		  invited()
	{
	}

	bool hasMember(int fd) const
	{
		return members.find(fd) != members.end();
	}

	bool isOperator(int fd) const
	{
		return operators.find(fd) != operators.end();
	}
};
