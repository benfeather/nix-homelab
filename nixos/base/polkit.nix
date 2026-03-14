{
  security.polkit = {
    enable = true;
    extraConfig = ''
      // Allow members of the "docker" group to start/stop/restart docker-*.service units without password
      polkit.addRule(function(action, subject) {
        if (
          action.id == "org.freedesktop.systemd1.manage-units" &&
          subject.isInGroup("docker")
        ) {
          var unit = action.lookup("unit");
          var verb = action.lookup("verb");

          if (
            unit &&
            unit.indexOf("docker-") == 0 &&
            unit.slice(-8) == ".service" &&
            (
              verb == "start" ||
              verb == "stop" ||
              verb == "restart"
            )
          ) {
            return polkit.Result.YES;
          }
        }
      });
    '';
  };
}
