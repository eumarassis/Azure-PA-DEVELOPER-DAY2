using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GPSSamples.PA.Day2.SBRelayWebApp.Models
{
    public class Product
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public string Quantity { get; set; }
    }

    public class ProductViewModel
    {

        public ProductViewModel()
        {
            this.NewProduct = new Product();
            this.ProductList = new List<Product>();
        }
        public Product NewProduct { get; set; }

        public  IEnumerable<Product> ProductList { get; set; }
    }
}