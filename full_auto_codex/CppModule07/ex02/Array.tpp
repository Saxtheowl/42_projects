template <typename T>
Array<T>::Array()
    : m_data(new T[0]), m_size(0)
{
}

template <typename T>
Array<T>::Array(unsigned int n)
    : m_data(new T[n]), m_size(n)
{
}

template <typename T>
Array<T>::Array(const Array &other)
    : m_data(new T[other.m_size]), m_size(other.m_size)
{
    for (unsigned int i = 0; i < m_size; ++i)
        m_data[i] = other.m_data[i];
}

template <typename T>
Array<T> &Array<T>::operator=(const Array &other)
{
    if (this != &other)
    {
        delete[] m_data;
        m_size = other.m_size;
        m_data = new T[m_size];
        for (unsigned int i = 0; i < m_size; ++i)
            m_data[i] = other.m_data[i];
    }
    return *this;
}

template <typename T>
Array<T>::~Array()
{
    delete[] m_data;
}

template <typename T>
unsigned int Array<T>::size() const
{
    return m_size;
}

template <typename T>
T &Array<T>::operator[](unsigned int index)
{
    if (index >= m_size)
        throw std::out_of_range("Index out of bounds");
    return m_data[index];
}

template <typename T>
const T &Array<T>::operator[](unsigned int index) const
{
    if (index >= m_size)
        throw std::out_of_range("Index out of bounds");
    return m_data[index];
}
