from django.test import TestCase

from todos.models import Todo

class TodoTestCase(TestCase):
    def setUp(self):
        Todo.objects.create(title="one", description="This is my todo one task.")
        Todo.objects.create(title="two", description="This in not my todo task!")
        Todo.objects.create(title="three", description="This in not my todo task!")

    def test_todos(self):
        """Check if todos have right descriptions"""
        one = Todo.objects.get(title="one")
        self.assertEqual(one.pk, 1)
