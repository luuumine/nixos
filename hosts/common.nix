{
  flake.nixosModules.common-config = {
    lumine.security = {
      auth = {
        primary = {
          pub = "sk-ssh-ed25519@openssh.com	AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAEtzWCKWmZgCzjiQFJerOarhJfcgZY8kZvs+CpCLEGOAAAABHNzaDo= lumine_primary";
          path = "~/.ssh/id_yubi_primary";
        };
        backup = {
          pub = "sk-ssh-ed25519@openssh.com	AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGqOn114ycM7dC5uXFehyFjqTWlz9BlY7YBvnvuOGItFAAAABHNzaDo= lumine_backup";
          path = "~/.ssh/id_yubi_backup";
        };
        phone = {
          pub = "ssh-ed25519	AAAAC3NzaC1lZDI1NTE5AAAAIOSF50b9uHqWXQgWC7T5dg2VMBYqI4T4I6VnEkm2R5aX lumine@phone";
          path = "~/.ssh/id_ed25519_phone";
        };
      };

      encryption = {
        admin = {
          pub = "ssh-ed25519	AAAAC3NzaC1lZDI1NTE5AAAAIAj6TFwjmQaxmMu4Nq87//lznYJ10XCdwLyKBkBg9yPY lumine_encryption";
          path = "~/.ssh/id_encryption";
        };
      };

      git.allowedSigners = [
        {
          email = "forgejo@luuumine.com";
          pub = "ssh-ed25519	AAAAC3NzaC1lZDI1NTE5AAAAIFpIOQUI+CJ527aWqxE5kxV58eL+sbgv1GWBKWbaTv77 forgejo";
        }
        {
          email = "romain@delhommais.com";
          pub = "ssh-ed25519	AAAAC3NzaC1lZDI1NTE5AAAAIOSF50b9uHqWXQgWC7T5dg2VMBYqI4T4I6VnEkm2R5aX	lumine";
        }
        {
          email = "romain@delhommais.com";
          pub = "sk-ssh-ed25519@openssh.com	AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIAEtzWCKWmZgCzjiQFJerOarhJfcgZY8kZvs+CpCLEGOAAAABHNzaDo= lumine_primary";
        }
      ];
    };
  };
}
