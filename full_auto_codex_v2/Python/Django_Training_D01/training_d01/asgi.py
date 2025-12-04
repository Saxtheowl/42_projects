"""
ASGI config for training_d01 project.
"""

import os

from django.core.asgi import get_asgi_application

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "training_d01.settings")

application = get_asgi_application()
