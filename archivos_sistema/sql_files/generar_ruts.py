import random
import os

ROOT_PATH = os.path.dirname(os.path.realpath(__file__))

# CTRL + ALT + FLECHAS.
names = [
    "Elizabeth Carlson"
    "Susan Hodge",
    "Marcus Stevens",
    "Andrew Smith",
    "Theodore Williams",
    "Debra Allen",
    "Jennifer Mason",
    "Laura Carrillo",
    "Nancy Murphy",
    "George Robinson",
]

def gen_rut(digits):
    min = pow(10, digits - 1)
    max = pow(10, digits) - 1
    return random.randint(min, max)

def create_queries_tp(name_arr):
    with open(os.path.join(ROOT_PATH, "queries_tp.sql"), "w") as tp_file:
        for name in name_arr:
            name_split = name.split()
            str_final = "INSERT INTO THERAPISTS (run_tp, speciality_tp, degrees_tp, pass_tp, email_tp, firstname_tp, lastname_tp, dv_tp) VALUES (" \
                "{}, '{}', '{}', '{}', '{}', '{}', '{}', {})".format(gen_rut(8), "Psicologo", "Clinico", "test123", name_split[0] + "@email.com",name_split[0], name_split[1], random.randint(0, 9)) + ";" + "\n"
            tp_file.write(str_final)

create_queries_tp(names)