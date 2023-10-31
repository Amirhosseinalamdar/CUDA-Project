import random

def get_input(prompt):
    return int(input(prompt))

def generate_float_matrix(lb, ub, n1, n2, percision):
    s = ""
    for i in range(n1):
        for j in range(n2):
            s += str(round(random.uniform(lb, ub), percision)) + " "
        s += "\n"
    return s


# random.seed(0)

n = get_input("please input m:\n")
m = get_input("please input n:\n")
k = get_input("please input k:\n")
s = str(m) + " " + str(n) + " " + str(k) + "\n"
lb = get_input("please input lower bound of elements:\n")
ub = get_input("please input upper bound of elements:\n")
percision = get_input("input the percision:\n")
s += generate_float_matrix(lb, ub, n, m, percision)
s += generate_float_matrix(lb, ub, m, k, percision)


file = open('sample.txt', 'w')
file.write(s)
file.close()