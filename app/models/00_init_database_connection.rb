# NOTE:
# An hack to initialize the database connection just when requiring model
# files. This can be improved once the application features are done.

DatabaseConnection.establish!
