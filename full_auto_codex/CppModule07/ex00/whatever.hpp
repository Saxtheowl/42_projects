template <typename T>
void swap(T &a, T &b)
{
    T tmp = a;
    a = b;
    b = tmp;
}

template <typename T>
T min(const T &a, const T &b)
{
    return (b < a) ? b : a;
}

template <typename T>
T max(const T &a, const T &b)
{
    return (a < b) ? b : a;
}
