import sys
import os
import shutil
import logging
import jinja2 as j2
import uuid
import base64

logging.basicConfig(level=logging.DEBUG)

env = {k: v
    for k, v in os.environ.items()}

jenv = j2.Environment(
    loader=j2.FileSystemLoader('/opt/jinja-templates/'),
    autoescape=j2.select_autoescape(['xml']))

def gen_cfg(tmpl, target):
    print(f"Generating {target} from template {tmpl}")
    cfg = jenv.get_template(tmpl).render(env)
    with open(target, 'w') as fd:
        fd.write(cfg)
