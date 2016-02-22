using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(GPSSamples.PA.Day2.SBRelayWebApp.Startup))]
namespace GPSSamples.PA.Day2.SBRelayWebApp
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
