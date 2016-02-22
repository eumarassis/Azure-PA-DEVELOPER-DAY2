using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using GPSSamples.PA.Day2.SBRelayWebApp.Models;
using ProductsServer;
using System.ServiceModel;
using Microsoft.ServiceBus;

namespace GPSSamples.PA.Day2.SBRelayWebApp.Controllers
{

    public class HomeController : Controller
    {
        // Declare the channel factory.
        static ChannelFactory<IProductsChannel> channelFactory;

        static HomeController() {
            // Create shared secret token credentials for authentication.
            channelFactory = new ChannelFactory<IProductsChannel>(new NetTcpRelayBinding(),
                "sb://eumar-azurepa.servicebus.windows.net/products");
            channelFactory.Endpoint.Behaviors.Add(new TransportClientEndpointBehavior
            {
                TokenProvider = TokenProvider.CreateSharedAccessSignatureTokenProvider(
                    "RootManageSharedAccessKey", "iRMmGMm6BqjT8OXvpbIPmAv3Bm2ewRidJFi0NX5+QLI=")
            });
        }
        // Return a view of the products inventory.
        public ActionResult Index(string Identifier, string ProductName)
        {
            using (IProductsChannel channel = channelFactory.CreateChannel())
            {
                ProductViewModel product = new ProductViewModel();

                product.ProductList = from prod in channel.GetProducts()
                                      select
                                          new Product
                                          {
                                              Id = prod.Id,
                                              Name = prod.Name,
                                              Quantity = prod.Quantity
                                          };

                // Return a view of the products inventory.
                return this.View(product);
            }

        }

        [HttpPost]
        [AllowAnonymous]
        public ActionResult AddProduct(ProductViewModel model)
        {
            using (IProductsChannel channel = channelFactory.CreateChannel())
            {
                ProductData newProduct = new ProductData()
                {
                    Name = model.NewProduct.Name,
                    Quantity = model.NewProduct.Quantity
                };

                channel.AddProduct(newProduct);

                model.ProductList = from prod in channel.GetProducts()
                                    select
                                        new Product
                                        {
                                            Id = prod.Id,
                                            Name = prod.Name,
                                            Quantity = prod.Quantity
                                        };

                // Return a view of the products inventory.
                return this.View("Index", model);
            }
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
    }
}