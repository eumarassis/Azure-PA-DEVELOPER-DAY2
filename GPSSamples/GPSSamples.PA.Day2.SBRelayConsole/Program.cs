using System;
using System.Linq;
using System.Collections.Generic;
using System.ServiceModel;

namespace ProductsServer
{
    // Implement the IProducts interface.
    class ProductsService : IProducts
    {
        internal static List<ProductData> ProductsList;

        static ProductsService()
        {
            ProductsList = new List<ProductData>(
                new[]
                {
                    new ProductData{ Id = "1", Name = "Rock",
                                     Quantity = "1"},
                    new ProductData{ Id = "2", Name = "Paper",
                                     Quantity = "3"},
                    new ProductData{ Id = "3", Name = "Scissors",
                                     Quantity = "5"},
                    new ProductData{ Id = "4", Name = "Well",
                                     Quantity = "2500"},
                }
            );
        }
   

        // Display a message in the service console application
        // when the list of products is retrieved.
        public IList<ProductData> GetProducts()
        {
            Console.WriteLine("GetProducts called from the Cloud.");
            return ProductsList;
        }

        public void AddProduct(ProductData item)
        {
            Console.WriteLine("Product Added {0}", item.Name);

            lock (ProductsList) {

                item.Id = (ProductsList.Count() + 1).ToString();
                ProductsList.Add(item);
            }
        }

    }

    class Program
    {
        // Define the Main() function in the service application.
        static void Main(string[] args)
        {
            var sh = new ServiceHost(typeof(ProductsService));
            sh.Open();

            Console.WriteLine("List of Products on Console");

            foreach (var item in ProductsService.ProductsList)
            {
                Console.WriteLine("Product: {0}", item.Name);
            }
            Console.WriteLine("Press ENTER to close");
            Console.ReadLine();

            sh.Close();
        }
    }

}
